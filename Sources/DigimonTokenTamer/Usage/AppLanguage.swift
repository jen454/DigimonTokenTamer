import Foundation

/// App language. Moved out of the upstream companion model (DigiMonTokenBar) so the usage
/// pipeline no longer depends on the game layer. The usage strings in `Localization.swift`
/// keep all eight languages; the Tamer UI is written in Korean with an English fallback.
enum AppLanguage: String, Codable, Sendable, CaseIterable {
    case ko, en, ja, es, fr, pt, de, ru

    var label: String {
        switch self { case .ko: return "한국어"; case .en: return "English"; case .ja: return "日本語"; case .es: return "Español"; case .fr: return "Français"; case .pt: return "Português"; case .de: return "Deutsch"; case .ru: return "Русский" }
    }

    var displayLocale: Locale { Locale(identifier: rawValue) }

    static var systemDefault: AppLanguage {
        systemDefault(for: Locale.preferredLanguages.first)
    }

    static func systemDefault(for preferredLanguage: String?) -> AppLanguage {
        switch preferredLanguage?.prefix(2).lowercased() {
        case "ko": return .ko
        case "ja": return .ja
        case "es": return .es
        case "fr": return .fr
        case "pt": return .pt
        case "de": return .de
        case "ru": return .ru
        default:   return .en
        }
    }
}
