import AppKit
import SwiftUI

/// Colours of the approved mockup (tools/crest_mockup.py): a light, paper-like card with
/// pixel sprites. The popover is pinned to the light appearance so it matches the mockup.
enum TamerPalette {
    static let background = Color(hex: "#f3f2ee")
    static let card = Color.white
    static let ink = Color(hex: "#222222")
    static let mute = Color(hex: "#8a8a8a")
    static let line = Color(hex: "#e4e2dc")
    static let orange = Color(hex: "#ff8a00")
    static let gauge = Color(hex: "#57b46a")
    static let link = Color(hex: "#2d6cdf")
    static let chip = Color(hex: "#f3f3f3")
    static let chipText = Color(hex: "#666666")
    static let hint = Color(hex: "#f7f6f2")
    static let okChip = Color(hex: "#e6f5e9")
    static let okText = Color(hex: "#2f8a44")
    static let stageTop = Color(hex: "#fbfaf6")
    static let stageBottom = Color(hex: "#f0eee6")
    static let cell = Color(hex: "#f7f6f2")
    static let nbLine = Color(hex: "#f0efea")
}

/// The usage views ported from DigiMonTokenBar refer to its cyber palette by name; the names now
/// resolve to the mockup's light colours so the ported code needs no rewrite.
enum CyberPalette {
    static let background = TamerPalette.background
    static let panel = TamerPalette.card
    static let panelRaised = TamerPalette.hint
    static let cyan = TamerPalette.link
    static let yellow = TamerPalette.orange
    static let text = TamerPalette.ink
    static let muted = TamerPalette.mute
    static let line = TamerPalette.line
}

extension Color {
    init(hex: String) {
        self.init(nsColor: NSColor(hex: hex))
    }
}

extension View {
    /// White rounded card with the mockup's soft shadow (`.pop`).
    func tamerCard(radius: CGFloat = 12) -> some View {
        background(RoundedRectangle(cornerRadius: radius).fill(TamerPalette.card))
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(TamerPalette.line, lineWidth: 0.5))
    }
}

/// Small grey section title (mockup `h2`).
struct TamerSectionHeading: View {
    let title: String
    var detail: String? = nil
    var body: some View {
        HStack {
            Text(title).font(.system(size: 11, weight: .semibold)).foregroundStyle(TamerPalette.mute)
            Spacer()
            if let detail { Text(detail).font(.system(size: 11)).foregroundStyle(TamerPalette.mute) }
        }
    }
}

/// Rounded progress bar (mockup `.bar`).
struct TamerBar: View {
    let fraction: Double
    var color: Color = TamerPalette.gauge
    var height: CGFloat = 8
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color(hex: "#eeeeee"))
                Capsule().fill(color).frame(width: geo.size.width * min(1, max(0, fraction)))
            }
        }
        .frame(height: height)
        .animation(.easeOut(duration: 0.6), value: fraction)
    }
}

/// Pill label (mockup `.chip` / `.chip.lit`).
struct TamerChip: View {
    let text: String
    var tint: Color? = nil
    var body: some View {
        Text(text)
            .font(.system(size: 11))
            .padding(.horizontal, 7).padding(.vertical, 2)
            .foregroundStyle(tint == nil ? TamerPalette.chipText : .white)
            .background(Capsule().fill(tint ?? TamerPalette.chip))
            .fixedSize()
    }
}

/// Small pill button used for in-text actions ("상점", "공식 도감 ↗", "따라가기") — tinted
/// instead of the default blue underlined link.
struct TextLink: View {
    let title: String
    var size: CGFloat = 12
    var tint: Color = TamerPalette.orange
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: size - 1, weight: .semibold))
                .foregroundStyle(tint)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(tint.opacity(0.12)))
                .overlay(Capsule().stroke(tint.opacity(0.35), lineWidth: 0.8))
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .fixedSize()
        .onHover { inside in if inside { NSCursor.pointingHand.push() } else { NSCursor.pop() } }
    }
}
