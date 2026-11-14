import AppKit
import SwiftUI

/// `DTT_RENDER_PREVIEWS=<dir>` renders the popover screens for each growth state to PNG and quits.
///
/// Used to check the UI against the mockup without clicking through the menu bar, and to make
/// README/presentation captures. It runs on a throwaway Tamer save; usage comes from a refresh of
/// the local logs with Keychain access off, so no prompt can appear.
@MainActor
enum PreviewRenderer {
    static func run(to directory: URL) async {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let pack = SpritePack.shared
        let nav = PopoverNavigation()
        let suite = "dtt-preview-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.set(true, forKey: "disableKeychainAccess")
        let store = UsageStore(autoRefresh: false, defaults: defaults)
        await store.refresh(scheduleEmptyRetry: false)

        let stateURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(suite).json")
        let tamer = TamerStore(fileURL: stateURL, defaults: defaults)
        store.localizationLanguage = tamer.language

        func shot(_ name: String, width: CGFloat = PopoverMetrics.width - PopoverMetrics.padding * 2,
                  @ViewBuilder _ content: () -> some View) {
            while tamer.currentEvent != nil { tamer.consumeEvent() }
            let view = content()
                .frame(width: width)
                .padding(PopoverMetrics.padding)
                .background(TamerPalette.background)
                .environment(store).environment(tamer).environment(nav).environment(pack)
                .environment(\.colorScheme, .light)
            let renderer = ImageRenderer(content: view)
            renderer.scale = 2
            guard let image = renderer.nsImage, let tiff = image.tiffRepresentation,
                  let png = NSBitmapImageRep(data: tiff)?.representation(using: .png, properties: [:]) else { return }
            try? png.write(to: directory.appendingPathComponent(name + ".png"))
        }
        func menuBar(_ name: String) {
            let subject: (String?, Bool) = {
                switch tamer.menuSubject {
                case .none: return (nil, true)
                case .egg(let line): return (tamer.catalog.line(line)?.eggSprite, true)
                case .form(let form): return (tamer.catalog.line(form.line)?.stages[form.stage].sprite, false)
                }
            }()
            let frames = MenuBarArt.loop(sprite: subject.0.flatMap { pack.sprite($0) }, isEgg: subject.1, ready: tamer.canEvolve)
            guard let first = frames.first else { return }
            let rep = NSBitmapImageRep(cgImage: first.cgImage)
            try? rep.representation(using: .png, properties: [:])?.write(to: directory.appendingPathComponent(name + ".png"))
        }

        let day = { (n: Int) in String(format: "2026-11-%02d", n) }
        shot("00-first-egg") { PartnerCard() }
        tamer.chooseFirstEgg("agumon")
        tamer.credit(2_000_000, date: day(1))
        shot("01-egg") { PartnerCard() }
        menuBar("menubar-egg")
        tamer.credit(1_000_000_000, date: day(1))
        shot("02-rookie-no-digivice") { PartnerCard() }
        menuBar("menubar-rookie")
        tamer.buy(.digivice)
        shot("03-rookie-ready") { PartnerCard() }
        menuBar("menubar-ready")
        tamer.evolve()
        tamer.credit(TamerBalance.gauge(stage: 3), date: day(2))
        shot("04-champion-no-pendant") { PartnerCard() }
        tamer.buy(.pendant)
        for d in 3...5 { tamer.credit(1_000, date: day(d)) }
        shot("05-champion-crest-off") { PartnerCard() }
        for d in 6...9 { tamer.credit(1_000, date: day(d)) }
        shot("06-champion-crest-lit-ready") { PartnerCard() }
        tamer.evolve()
        tamer.credit(TamerBalance.gauge(stage: 4), date: day(10))
        tamer.credit(400_000_000, date: day(10))
        for _ in 0..<6 { tamer.buy(.meat) }
        for _ in 0..<6 { tamer.feedMeat() }
        tamer.buy(.meat)
        shot("07-ultimate-bond") { PartnerCard() }
        shot("08-shop") { ShopView() }
        shot("09-notebook") { NotebookView() }
        shot("10-data-traffic") {
            VStack(spacing: 12) {
                UsageDetailsPanel(l: tamer.l, title: tamer.text.dataTraffic)
                LimitsPanel(l: tamer.l, language: tamer.language, title: tamer.text.limitsTitle)
            }
        }
        shot("11-home") {
            VStack(spacing: 12) {
                PartnerCard()
                UsageDetailsPanel(l: tamer.l, title: tamer.text.dataTraffic)
            }
        }
        try? FileManager.default.removeItem(at: stateURL)
        UserDefaults.standard.removePersistentDomain(forName: suite)
    }
}
