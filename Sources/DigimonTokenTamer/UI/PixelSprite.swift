import SwiftUI

/// A sprite drawn at an integer multiple of its native pixels, without interpolation
/// (DESIGN §5.1 "PNG + SwiftUI `.interpolation(.none)`").
struct PixelSprite: View {
    enum Mode { case normal, silhouette, black, white, dim, grey }

    @Environment(SpritePack.self) private var pack
    let path: String
    /// Points per sprite pixel. Nil fits the sprite into `fit` at the largest integer scale.
    var scale: CGFloat? = nil
    var fit: CGSize? = nil
    var mode: Mode = .normal
    var flipped = false
    /// Size used while the sprite pack is missing, so layouts do not jump.
    var placeholder = CGSize(width: 32, height: 32)

    var body: some View {
        if let sprite = pack.sprite(path) {
            let s = resolvedScale(sprite.pixels)
            let size = CGSize(width: sprite.pixels.width * s, height: sprite.pixels.height * s)
            image(sprite)
                .frame(width: size.width, height: size.height)
                .scaleEffect(x: flipped ? -1 : 1, y: 1)
        } else {
            RoundedRectangle(cornerRadius: 4)
                .stroke(TamerPalette.line, style: StrokeStyle(lineWidth: 1, dash: [3]))
                .frame(width: placeholder.width, height: placeholder.height)
        }
    }

    @ViewBuilder
    private func image(_ sprite: SpritePack.Sprite) -> some View {
        let base = Image(nsImage: sprite.image).interpolation(.none).resizable()
        switch mode {
        case .normal: base
        case .dim: base.brightness(-0.25)
        case .grey: base.grayscale(1).brightness(0.1).opacity(0.45)
        case .silhouette: base.renderingMode(.template).foregroundStyle(Color.black.opacity(0.18))
        case .black: base.renderingMode(.template).foregroundStyle(Color(hex: "#151515"))
        case .white: base.renderingMode(.template).foregroundStyle(Color.white)
        }
    }

    private func resolvedScale(_ pixels: CGSize) -> CGFloat {
        if let scale { return scale }
        guard let fit else { return 1 }
        let raw = min(fit.width / max(pixels.width, 1), fit.height / max(pixels.height, 1))
        // Integer scale keeps every dot square; below 1 the sprite has to shrink.
        return raw >= 1 ? raw.rounded(.down) : raw
    }
}

/// An original pixel icon (the "!" badge, sparks…) as a SwiftUI image.
struct PixelIconView: View {
    let icon: PixelIcon
    var dot: CGFloat = 3
    var body: some View {
        Image(nsImage: icon.image(dot: dot)).interpolation(.none)
    }
}
