import AppKit

/// Overlay icons drawn for this app (tools/motion_lab.py ICONS) — original pixel art, safe to ship.
enum PixelIcon: Equatable, Sendable {
    case exclamation, spark, heart, sleep, note, anger

    var rows: [String] {
        switch self {
        case .exclamation: return [".aa.", "baab", "baab", "baab", ".bb.", "....", ".aa.", "baab", ".bb."]
        case .spark: return ["..a..", "..a..", "aabaa", "..a..", "..a.."]
        case .heart: return [".aa.aa.", "abaaaaa", "aaaaaaa", ".aaaaa.", "..aaa..", "...a..."]
        case .sleep: return ["aaaa", "..a.", ".a..", "aaaa"]
        case .note: return ["..aa", "..a.", "..a.", "aaa.", "aa.."]
        case .anger: return [".a.a.", "aa.aa", ".....", "aa.aa", ".a.a."]
        }
    }

    var palette: [Character: NSColor] {
        switch self {
        case .exclamation: return ["a": NSColor(hex: "#ff8a00"), "b": NSColor(hex: "#7a3b00")]
        case .spark: return ["a": NSColor(hex: "#ffcc00"), "b": NSColor(hex: "#fff3a0")]
        case .heart: return ["a": NSColor(hex: "#e0245e"), "b": NSColor(hex: "#ff8fb1")]
        case .sleep: return ["a": NSColor(hex: "#5566aa")]
        case .note: return ["a": NSColor(hex: "#333333")]
        case .anger: return ["a": NSColor(hex: "#e03a3a")]
        }
    }

    var size: CGSize { CGSize(width: rows.map(\.count).max() ?? 0, height: rows.count) }

    /// Draws with the top-left corner at `origin` (top-left based), `dot` device pixels per dot.
    func draw(in ctx: CGContext, origin: CGPoint, dot: CGFloat, canvasHeight: CGFloat) {
        for (j, row) in rows.enumerated() {
            for (i, ch) in row.enumerated() {
                guard let color = palette[ch] else { continue }
                ctx.setFillColor(color.cgColor)
                let y = canvasHeight - (origin.y + CGFloat(j + 1) * dot)
                ctx.fill(CGRect(x: origin.x + CGFloat(i) * dot, y: y, width: dot, height: dot))
            }
        }
    }

    /// The icon as an image at `dot` points per dot, for SwiftUI.
    func image(dot: CGFloat = 1) -> NSImage {
        let w = size.width * dot, h = size.height * dot
        let image = NSImage(size: NSSize(width: w, height: h), flipped: true) { _ in
            for (j, row) in rows.enumerated() {
                for (i, ch) in row.enumerated() {
                    guard let color = palette[ch] else { continue }
                    color.setFill()
                    NSRect(x: CGFloat(i) * dot, y: CGFloat(j) * dot, width: dot, height: dot).fill()
                }
            }
            return true
        }
        return image
    }
}

extension NSColor {
    convenience init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))).scanHexInt64(&value)
        self.init(srgbRed: CGFloat((value >> 16) & 0xff) / 255, green: CGFloat((value >> 8) & 0xff) / 255,
                  blue: CGFloat(value & 0xff) / 255, alpha: 1)
    }
}
