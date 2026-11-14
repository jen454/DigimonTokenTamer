import AppKit
import Observation

/// Loads the pixel sprites at their native size (DESIGN §5).
///
/// The artwork is fan-use material and is never committed or bundled (DESIGN §5.2). The app
/// reads it from, in order:
/// 1. `DTT_SPRITES_DIR` — a development override (e.g. the repo's `assets/build`).
/// 2. `~/Library/Application Support/DigimonTokenTamer/sprites/` — the download cache, also
///    filled by `scripts/install-sprites.sh` during development.
/// 3. The sprite pack repository (`defaultBaseURL`, overridable in Settings), downloaded on first
///    launch like DigiMonTokenBar's runtime artwork: a GitHub download works without any setup.
///    The app never fetches from Wikimon or Namuwiki directly.
@MainActor
@Observable
final class SpritePack {
    static let shared = SpritePack()

    struct Sprite {
        let image: NSImage
        /// Native pixel size, the unit every layout in the app is based on.
        let pixels: CGSize
    }

    static let baseURLKey = "spritePackBaseURL"
    /// Separate public repository holding only the sprite PNGs in the pack layout
    /// (`scripts/package-sprites.sh` builds its contents). Not the code repository: DESIGN §5.2.
    static let defaultBaseURL = "https://raw.githubusercontent.com/jen454/DigimonTokenTamer-sprites/main/"
    /// A failed file is retried after this long, so a missing file never turns into a request per poll.
    static let retryInterval: TimeInterval = 600

    /// Bumped whenever a download lands, so views showing a placeholder look again.
    private(set) var generation = 0

    @ObservationIgnored private var cache: [String: Sprite] = [:]
    @ObservationIgnored private var missing: Set<String> = []
    @ObservationIgnored private var downloading: Set<String> = []
    @ObservationIgnored private var failedAt: [String: Date] = [:]
    @ObservationIgnored private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    nonisolated static var installDirectory: URL {
        AppStatePaths.directory().appendingPathComponent("sprites", isDirectory: true)
    }

    nonisolated static var searchDirectories: [URL] {
        var dirs: [URL] = []
        let env = (ProcessInfo.processInfo.environment["DTT_SPRITES_DIR"] ?? "").trimmingCharacters(in: .whitespaces)
        if !env.isEmpty { dirs.append(URL(fileURLWithPath: env, isDirectory: true)) }
        dirs.append(installDirectory)
        return dirs
    }

    var baseURL: String {
        get {
            // Development/QA: point at a local copy of the pack (`python3 -m http.server`).
            let env = (ProcessInfo.processInfo.environment["DTT_SPRITES_URL"] ?? "").trimmingCharacters(in: .whitespaces)
            if !env.isEmpty { return env }
            let stored = (defaults.string(forKey: Self.baseURLKey) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            return stored.isEmpty ? Self.defaultBaseURL : stored
        }
        set {
            // Clearing the field (or entering the default) goes back to the default host.
            let value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if value.isEmpty || value == Self.defaultBaseURL {
                defaults.removeObject(forKey: Self.baseURLKey)
            } else {
                defaults.set(value, forKey: Self.baseURLKey)
            }
            failedAt.removeAll()
            reload()
        }
    }

    /// The sprite at `path` (relative to the pack root), or nil while it is unavailable.
    func sprite(_ path: String) -> Sprite? {
        _ = generation   // observe downloads
        if let hit = cache[path] { return hit }
        if missing.contains(path) { return nil }
        for dir in Self.searchDirectories {
            let url = dir.appendingPathComponent(path)
            if let sprite = Self.decode(url) {
                cache[path] = sprite
                return sprite
            }
        }
        missing.insert(path)
        download(path)
        return nil
    }

    func reload() {
        cache.removeAll()
        missing.removeAll()
        generation += 1
    }

    /// Looks again only if something was missing — e.g. the sprites were installed while the app
    /// ran. Called when the popover opens, so no restart or Settings visit is needed.
    func reloadIfMissing() {
        guard !missing.isEmpty else { return }
        reload()
    }

    /// True when not even the basic item sprites resolve: the pack is not installed at all.
    var isMissing: Bool {
        sprite(TamerAssets.digivice) == nil && sprite(TamerAssets.meat) == nil
    }

    /// First launch: request every sprite the app can show, so the notebook's silhouettes and the
    /// shop are complete before they are opened. Files already cached cost nothing.
    func prefetch(_ paths: [String]) {
        for path in paths { _ = sprite(path) }
    }

    /// How many of `paths` resolve — the Settings status line.
    func availability(of paths: [String]) -> Int {
        paths.reduce(0) { $0 + (sprite($1) == nil ? 0 : 1) }
    }

    private nonisolated static func decode(_ url: URL) -> Sprite? {
        guard let data = try? Data(contentsOf: url), let rep = NSBitmapImageRep(data: data) else { return nil }
        let pixels = CGSize(width: rep.pixelsWide, height: rep.pixelsHigh)
        let image = NSImage(size: pixels)
        image.addRepresentation(rep)
        return Sprite(image: image, pixels: pixels)
    }

    private func download(_ path: String) {
        let base = baseURL
        if let failed = failedAt[path], Date().timeIntervalSince(failed) < Self.retryInterval { return }
        guard !base.isEmpty, !downloading.contains(path),
              let root = URL(string: base.hasSuffix("/") ? base : base + "/"), Self.isAllowedHost(root),
              !(root.host ?? "").contains("wikimon"),
              let url = URL(string: path, relativeTo: root)?.absoluteURL else { return }
        downloading.insert(path)
        let target = Self.installDirectory.appendingPathComponent(path)
        Task {
            defer { downloading.remove(path) }
            guard let (data, response) = try? await URLSession.shared.data(from: url),
                  (response as? HTTPURLResponse)?.statusCode == 200,
                  data.count < 2_000_000, NSBitmapImageRep(data: data) != nil else {
                failedAt[path] = Date()
                AppLog.writeIfChanged("sprite-download-\(path)", "sprite download failed: \(path)")
                return
            }
            try? FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
            guard (try? data.write(to: target, options: .atomic)) != nil else { return }
            missing.remove(path)
            failedAt[path] = nil
            generation += 1
        }
    }

    /// HTTPS only, except a local server during development.
    nonisolated static func isAllowedHost(_ url: URL) -> Bool {
        if url.scheme == "https" { return true }
        return url.scheme == "http" && ["127.0.0.1", "localhost"].contains(url.host ?? "")
    }

    /// Every sprite path the app can ask for, for the availability check.
    static func allPaths(_ catalog: TamerCatalog) -> [String] {
        var paths = [TamerAssets.digivice, TamerAssets.meat, TamerAssets.emptyPendant]
        for line in catalog.lines {
            paths += line.stages.map(\.sprite)
            paths += [line.eggSprite, line.crestSprite, line.pendantSprite, line.pendantOffSprite]
        }
        return paths
    }
}
