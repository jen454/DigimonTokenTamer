import AppKit

/// Menu bar frames (DESIGN §3.1, motion lab "idle" and "ready").
///
/// The icon is 54×22 pt so the "!" badge has room to the right of the character. Sprites up to
/// 22 px tall are drawn at an integer scale with nearest-neighbour sampling; taller ones are
/// scaled down to fit, which the design accepted after checking in the motion lab.
enum MenuBarArt {
    struct Frame {
        let image: NSImage
        let cgImage: CGImage
        let delay: TimeInterval
    }

    static let pointSize = NSSize(width: 54, height: 22)
    /// Device pixels per point: frames are rendered for Retina and downsampled by AppKit elsewhere.
    static let scale: CGFloat = 2
    private static var pixelWidth: CGFloat { pointSize.width * scale }
    private static var pixelHeight: CGFloat { pointSize.height * scale }
    /// Horizontal centre of the character, in device pixels — leaves the right side for "!".
    private static let centerX: CGFloat = 44

    /// Device pixels per sprite dot (motion lab: `h<=22?2:h<=44?1:44/h`), narrowed for wide sprites.
    static func dotScale(for pixels: CGSize) -> CGFloat {
        let h = max(pixels.height, 1), w = max(pixels.width, 1)
        let byHeight: CGFloat = h <= 22 ? 2 : (h <= 44 ? 1 : 44 / h)
        return min(byHeight, 76 / w)
    }

    /// The looping frames for one subject. `ready` adds the bobbing "!" badge.
    static func loop(sprite: SpritePack.Sprite?, isEgg: Bool, ready: Bool) -> [Frame] {
        guard let sprite else { return placeholder(isEgg: isEgg) }
        if ready {
            return (0..<8).compactMap { k in
                render(sprite, up: k % 2 == 1, flip: false, badgeBob: k % 2, overlay: nil, delay: 0.3)
            }
        }
        if isEgg {
            return [render(sprite, up: false, flip: false, badgeBob: nil, overlay: nil, delay: 0.6),
                    render(sprite, up: true, flip: false, badgeBob: nil, overlay: nil, delay: 0.6)].compactMap { $0 }
        }
        // Idle: three bobs facing right, three facing left (motion lab `idle`).
        var frames: [Frame] = []
        for flip in [false, true] {
            for k in 0..<6 {
                if let f = render(sprite, up: k % 2 == 1, flip: flip, badgeBob: nil, overlay: nil, delay: 0.5) { frames.append(f) }
            }
        }
        return frames
    }

    /// A one-off sequence: the crest twinkles next to the character (DESIGN §3.1, 1–2 s).
    static func crestTwinkle(sprite: SpritePack.Sprite?, crest: SpritePack.Sprite?) -> [Frame] {
        guard let sprite, let crest else { return [] }
        return [1.0, 0.55, 1.0, 0.35].compactMap { alpha in
            render(sprite, up: false, flip: false, badgeBob: nil, overlay: (crest, alpha), delay: 0.4)
        }
    }

    private static func render(_ sprite: SpritePack.Sprite, up: Bool, flip: Bool, badgeBob: Int?,
                               overlay: (SpritePack.Sprite, CGFloat)?, delay: TimeInterval) -> Frame? {
        guard let ctx = CGContext(data: nil, width: Int(pixelWidth), height: Int(pixelHeight), bitsPerComponent: 8,
                                  bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let cg = sprite.image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        let s = dotScale(for: sprite.pixels)
        let w = (sprite.pixels.width * s).rounded(), h = (sprite.pixels.height * s).rounded()
        let x = (centerX - w / 2).rounded()
        let y: CGFloat = 1 + (up ? 2 : 0)   // bottom-aligned, bob by one point
        ctx.interpolationQuality = s >= 1 ? .none : .medium
        ctx.saveGState()
        if flip {
            ctx.translateBy(x: x * 2 + w, y: 0)
            ctx.scaleBy(x: -1, y: 1)
        }
        ctx.draw(cg, in: CGRect(x: x, y: y, width: w, height: h))
        ctx.restoreGState()

        let right = x + w
        if let bob = badgeBob {
            let icon = PixelIcon.exclamation
            let dot: CGFloat = 2
            let bx = min(right + 2, pixelWidth - icon.size.width * dot)
            icon.draw(in: ctx, origin: CGPoint(x: bx, y: CGFloat(3 - bob * 2)), dot: dot, canvasHeight: pixelHeight)
        }
        if let (crest, alpha) = overlay, let crestCG = crest.image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            ctx.interpolationQuality = .none
            ctx.setAlpha(alpha)
            let size: CGFloat = 36
            ctx.draw(crestCG, in: CGRect(x: min(right + 1, pixelWidth - size), y: pixelHeight - size - 2, width: size, height: size))
        }
        guard let image = ctx.makeImage() else { return nil }
        let ns = NSImage(cgImage: image, size: pointSize)
        return Frame(image: ns, cgImage: image, delay: delay)
    }

    /// No sprite pack yet: an outlined egg or a dot, so the item is never invisible.
    private static func placeholder(isEgg: Bool) -> [Frame] {
        guard let ctx = CGContext(data: nil, width: Int(pixelWidth), height: Int(pixelHeight), bitsPerComponent: 8,
                                  bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return [] }
        ctx.setStrokeColor(NSColor.labelColor.cgColor)
        ctx.setLineWidth(3)
        let rect = isEgg ? CGRect(x: centerX - 13, y: 4, width: 26, height: 34) : CGRect(x: centerX - 14, y: 6, width: 28, height: 28)
        ctx.strokeEllipse(in: rect)
        guard let image = ctx.makeImage() else { return [] }
        return [Frame(image: NSImage(cgImage: image, size: pointSize), cgImage: image, delay: 1)]
    }
}
