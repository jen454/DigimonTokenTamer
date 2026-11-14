import AppKit
import SwiftUI

/// Desktop pet (opt-in, as DigiMonTokenBar's floating pet): the menu bar subject in a small
/// borderless, always-on-top panel. Drag to move (the position is remembered), click to open the
/// popover, right-click for a menu. It never walks around on its own.
@MainActor
final class FloatingPetController: NSObject, NSWindowDelegate {
    private let store: UsageStore
    private let tamer: TamerStore
    private let pack: SpritePack
    private let onOpenPopover: () -> Void
    private var panel: NSPanel?
    static let originKey = "floatingPetOrigin"

    init(store: UsageStore, tamer: TamerStore, pack: SpritePack, onOpenPopover: @escaping () -> Void) {
        self.store = store
        self.tamer = tamer
        self.pack = pack
        self.onOpenPopover = onOpenPopover
        super.init()
        observe()
        sync()
    }

    private func observe() {
        withObservationTracking {
            _ = store.floatingPetEnabled
            _ = store.floatingPetSize
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.sync()
                self?.observe()
            }
        }
    }

    private var contentSize: NSSize {
        let side = CGFloat(store.floatingPetSize)
        // Room for a form scaled up to ~1.5× the size setting plus the "!" and the bob.
        return NSSize(width: side * 1.5 + 24, height: side * 1.5 + 20)
    }

    func sync() {
        guard store.floatingPetEnabled else {
            panel?.orderOut(nil)
            return
        }
        let panel = self.panel ?? makePanel()
        self.panel = panel
        if panel.frame.size != contentSize {
            let origin = panel.frame.origin
            panel.setFrame(NSRect(origin: origin, size: contentSize), display: true)
        }
        panel.orderFrontRegardless()
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(contentRect: NSRect(origin: savedOrigin() ?? defaultOrigin(), size: contentSize),
                            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.delegate = self
        let host = PetHostingView(rootView: AnyView(
            FloatingPetView().environment(store).environment(tamer).environment(pack)))
        host.onClick = { [weak self] in
            guard let self, self.tamer.active?.isEgg == false else { return }
            self.tamer.perform(.pet)
        }
        host.onDoubleClick = { [weak self] in self?.onOpenPopover() }
        host.menuProvider = { [weak self] in self?.contextMenu() }
        panel.contentView = host
        return panel
    }

    private func contextMenu() -> NSMenu {
        let t = tamer.text
        let menu = NSMenu()
        menu.addItem(ActionMenuItem(title: t.openPopover) { [weak self] in self?.onOpenPopover() })
        if tamer.active?.isEgg == false {
            menu.addItem(ActionMenuItem(title: t.petAction) { [weak self] in self?.tamer.perform(.pet) })
        }
        if tamer.state.meat > 0, tamer.active?.isEgg == false {
            menu.addItem(ActionMenuItem(title: t.feedMeat(tamer.state.meat)) { [weak self] in self?.tamer.feedMeat() })
        }
        menu.addItem(.separator())
        menu.addItem(ActionMenuItem(title: t.petHide) { [weak self] in self?.store.floatingPetEnabled = false })
        return menu
    }

    // MARK: Position

    func windowDidMove(_ notification: Notification) {
        guard let origin = panel?.frame.origin else { return }
        UserDefaults.standard.set([origin.x, origin.y], forKey: Self.originKey)
    }

    private func savedOrigin() -> NSPoint? {
        guard let xy = UserDefaults.standard.array(forKey: Self.originKey) as? [Double], xy.count == 2 else { return nil }
        let point = NSPoint(x: xy[0], y: xy[1])
        // Ignore a position left on a display that is no longer connected.
        return NSScreen.screens.contains { $0.visibleFrame.insetBy(dx: -40, dy: -40).contains(point) } ? point : nil
    }

    private func defaultOrigin() -> NSPoint {
        let frame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1280, height: 800)
        return NSPoint(x: frame.maxX - contentSize.width - 40, y: frame.minY + 40)
    }
}

/// Click vs. drag on a borderless panel: a press that moves less than a few points is a click.
/// Click pets the partner, double-click opens the popover.
private final class PetHostingView: NSHostingView<AnyView> {
    var onClick: (() -> Void)?
    var onDoubleClick: (() -> Void)?
    var menuProvider: (() -> NSMenu?)?
    private var pressLocation: NSPoint?
    private var pressOrigin: NSPoint?
    private var dragged = false

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        pressLocation = NSEvent.mouseLocation
        pressOrigin = window?.frame.origin
        dragged = false
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = pressLocation, let origin = pressOrigin, let window else { return }
        let now = NSEvent.mouseLocation
        let dx = now.x - start.x, dy = now.y - start.y
        if !dragged, hypot(dx, dy) < 3 { return }
        dragged = true
        window.setFrameOrigin(NSPoint(x: origin.x + dx, y: origin.y + dy))
    }

    override func mouseUp(with event: NSEvent) {
        if !dragged { event.clickCount >= 2 ? onDoubleClick?() : onClick?() }
        pressLocation = nil
        pressOrigin = nil
    }

    override func rightMouseDown(with event: NSEvent) {
        guard let menu = menuProvider?() else { return }
        NSMenu.popUpContextMenu(menu, with: event, for: self)
    }
}

/// An NSMenuItem that runs a closure.
private final class ActionMenuItem: NSMenuItem {
    private let handler: () -> Void
    init(title: String, handler: @escaping () -> Void) {
        self.handler = handler
        super.init(title: title, action: #selector(run), keyEquivalent: "")
        target = self
    }
    required init(coder: NSCoder) { fatalError("init(coder:) is not used") }
    @objc private func run() { handler() }
}

/// The pet itself: the menu bar subject bobbing on a soft shadow, with the "!" when ready.
@MainActor
struct FloatingPetView: View {
    @Environment(UsageStore.self) private var store
    @Environment(TamerStore.self) private var tamer
    @Environment(SpritePack.self) private var pack

    private var path: String? {
        switch tamer.menuSubject {
        case .none: return nil
        case .egg(let line): return tamer.catalog.line(line)?.eggSprite
        case .form(let form): return tamer.catalog.line(form.line)?.stages[form.stage].sprite
        }
    }

    var body: some View {
        let side = CGFloat(store.floatingPetSize)
        ZStack(alignment: .bottom) {
            Ellipse().fill(Color.black.opacity(0.18)).frame(width: side * 0.6, height: 6)
            if let path {
                // Nearest whole scale to the chosen size: dots stay square and big forms do not
                // shrink to 1× just because they are a little over the size.
                let pixels = pack.sprite(path)?.pixels ?? CGSize(width: side, height: side)
                let scale = max(1, (side / max(pixels.width, pixels.height)).rounded())
                let room = side * 1.5 + 24
                MotionSprite(path: path, scale: scale, mood: PartnerMood.current(usage: store, tamer: tamer),
                             action: tamer.action, actionID: tamer.actionID, actionAt: tamer.actionAt,
                             walkRange: max(2, Int((room - pixels.width * scale) / 2 / scale) - 2))
                    .overlay(alignment: .topTrailing) {
                        if tamer.canEvolve {
                            PixelIconView(icon: .exclamation, dot: max(2, scale))
                                .offset(x: 4 * scale, y: -4 * scale)
                        }
                    }
                    .padding(.bottom, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .help(tamer.active.map { tamer.name(of: $0) } ?? "")
    }
}
