import Foundation

/// The eight Digimon Adventure partner lines × six stages (docs/DESIGN.md §1).
///
/// Source: `Resources/Tamer/catalog.json`, compiled in (see `TamerCatalogData`). It holds names,
/// crest colours and the sprite pack paths only — the artwork itself is never bundled (DESIGN §5.2).
struct TamerCatalog: Decodable, Sendable {
    struct Crest: Decodable, Sendable, Equatable {
        let key: String
        let ko: String
        let en: String
        let color: String
    }
    struct Localized: Decodable, Sendable, Equatable {
        let ko: String
        let en: String
        func text(_ lang: AppLanguage) -> String { lang == .ko ? ko : en }
    }
    struct LocalizedList: Decodable, Sendable, Equatable {
        let ko: [String]
        let en: [String]
        func list(_ lang: AppLanguage) -> [String] { lang == .ko ? ko : en }
    }
    /// Short profile facts shown next to the gauge (as DigiMonTokenBar's home card).
    /// Absent for the four In-Training I forms its data does not cover.
    struct Info: Decodable, Sendable, Equatable {
        let type: Localized
        let attribute: Localized
        let moves: LocalizedList
        /// Official reference page (digimon.net). The app links to it instead of quoting the profile.
        var source: Localized? = nil
    }
    struct Stage: Decodable, Sendable, Equatable {
        /// English name (Vital Bracelet / Japanese romanisation, as the sprite pack).
        let name: String
        /// Official Korean name (digimon.net reference_ko — the localized Adventure names).
        var ko: String? = nil
        /// True for the four forms without an official Korean entry (transliterated).
        var koUnverified: Bool? = nil
        /// Sprite path relative to the sprite pack root (`png/agumon/2_rookie_agumon.png`).
        let sprite: String
        var info: Info? = nil

        func displayName(_ lang: AppLanguage) -> String { lang == .ko ? (ko ?? name) : name }
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

    /// Decoded from `TamerCatalogData` — `catalog.json` compiled in by `scripts/gen-catalog.sh`.
    static let shared: TamerCatalog = {
        guard let catalog = try? JSONDecoder().decode(TamerCatalog.self, from: Data(TamerCatalogData.json.utf8)) else {
            preconditionFailure("Invalid embedded Tamer catalog")
        }
        return catalog
    }()
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
