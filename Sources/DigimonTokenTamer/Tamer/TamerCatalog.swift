import Foundation

/// The eight Digimon Adventure partner lines × six stages (docs/DESIGN.md §1).
///
/// Loaded from `Resources/Tamer/catalog.json`. The file holds names, crest colours and the
/// sprite pack paths only — the artwork itself is never bundled (DESIGN §5.2).
struct TamerCatalog: Decodable, Sendable {
    struct Crest: Decodable, Sendable, Equatable {
        let key: String
        let ko: String
        let en: String
        let color: String
    }
    struct Stage: Decodable, Sendable, Equatable {
        let name: String
        /// Sprite path relative to the sprite pack root (`png/agumon/2_rookie_agumon.png`).
        let sprite: String
    }
    struct Line: Decodable, Sendable, Equatable, Identifiable {
        let key: String
        let ko: String
        let crest: Crest
        let stages: [Stage]
        var id: String { key }

        var eggSprite: String { "digitama/\(key).png" }
        var crestSprite: String { "crests/\(key).png" }
        var pendantSprite: String { "items/pendant_\(key).png" }
        var pendantOffSprite: String { "items/pendant_\(key)_off.png" }
    }
    struct StageName: Decodable, Sendable {
        let key: String
        let ko: String
        let en: String
    }

    let version: Int
    let stages: [StageName]
    let lines: [Line]

    static let stageCount = 6

    func line(_ key: String) -> Line? { lines.first { $0.key == key } }

    func stageName(_ index: Int, _ lang: AppLanguage) -> String {
        guard stages.indices.contains(index) else { return "" }
        return lang == .ko ? stages[index].ko : stages[index].en
    }

    static let shared: TamerCatalog = {
        guard let url = resourceURL("catalog", ext: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(TamerCatalog.self, from: data) else {
            preconditionFailure("Missing or invalid Tamer catalog")
        }
        return catalog
    }()

    /// The assembled app carries `Tamer/` directly in Contents/Resources; `swift run` uses the
    /// SwiftPM resource bundle. A missing file in the app returns nil instead of touching
    /// `Bundle.module`, whose accessor traps when the bundle is absent.
    static func resourceURL(_ name: String, ext: String, applicationBundle: Bundle = .main) -> URL? {
        if let url = applicationBundle.url(forResource: name, withExtension: ext, subdirectory: "Tamer") { return url }
        if applicationBundle.bundleURL.pathExtension == "app" { return nil }
        return Bundle.module.url(forResource: name, withExtension: ext, subdirectory: "Tamer")
    }
}

/// Shop and sprite assets that are not tied to one line.
enum TamerAssets {
    static let digivice = "items/digivice.png"
    static let meat = "items/meat.png"
    static let emptyPendant = "items/pendant.png"
}

/// A form in the notebook: one line at one stage.
struct FormRef: Codable, Hashable, Sendable {
    let line: String
    let stage: Int

    var key: String { "\(line):\(stage)" }
}
