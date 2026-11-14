import AppKit
import QuartzCore
import SwiftUI
import UserNotifications

@main
@MainActor
struct DigimonTokenTamerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // The menu bar item is an NSStatusItem owned by AppDelegate (upstream: MenuBarExtra
        // re-renders too often for a label that changes every refresh).
        Settings { EmptyView() }
    }
}

/// Menu bar item, popover and the wiring from usage to growth.
///
/// Based on DigiMonTokenBar's AppDelegate: single instance, crash log, SIGPIPE guard, the
/// sprite drawn through a dedicated CALayer (frame swaps never redraw the text), animation paused
/// while the display sleeps or the popover is open, and the popover's hosting tree released on close.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private var outsideClickMonitor = OutsideClickMonitor()
    private var store: UsageStore!
    private var tamer: TamerStore!
    private let pack = SpritePack.shared
    private let navigation = PopoverNavigation()
    private var floatingPet: FloatingPetController?

    private var frames: [MenuBarArt.Frame] = []
    private var frameIndex = 0
    private var frameTimer: Timer?
    private var framesKey: String?
    private var oneShot: [MenuBarArt.Frame] = []
    private var displayAwake = true
    private let spriteLayer = CALayer()
    private var placeholderSize: NSSize?
    private var needsSpriteLayout = true
    private var lastCrestEvents = 0

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let dir = ProcessInfo.processInfo.environment["DTT_RENDER_PREVIEWS"], !dir.isEmpty {
            NSApp.setActivationPolicy(.accessory)
            Task { @MainActor in
                await PreviewRenderer.run(to: URL(fileURLWithPath: dir, isDirectory: true))
                NSApp.terminate(nil)
            }
            return
        }
        if SingleInstance.shouldYieldToRunningInstance() {
            AppLog.writeAndFlush("duplicate instance: yielding to the instance already running")
            NSApp.terminate(nil)
            return
        }
        signal(SIGPIPE, SIG_IGN)
        CrashReporter.install(
            version: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?")
        NSApp.setActivationPolicy(.accessory)
        UserDefaults.standard.register(defaults: ["NSInitialToolTipDelay": 600])

        store = UsageStore()
        tamer = TamerStore()
        store.localizationLanguage = tamer.language
        store.onRefresh = { [weak self] in self?.onStoreRefreshed() }
        tamer.onNotify = { [weak self] title, body in self?.postNotification(title, body) }
        lastCrestEvents = crestEventCount
        pack.prefetch(SpritePack.allPaths(tamer.catalog))   // first launch downloads the sprite pack
        floatingPet = FloatingPetController(store: store, tamer: tamer, pack: pack,
                                            onOpenPopover: { [weak self] in self?.showPopover() })

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.imagePosition = .imageLeading
            button.imageHugsTitle = true   // no extra gap between the character and the numbers
            button.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
            button.cell?.usesSingleLineMode = false
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.wantsLayer = true
            spriteLayer.magnificationFilter = .nearest
            spriteLayer.minificationFilter = .linear
            spriteLayer.contentsGravity = .resizeAspect
            button.layer?.addSublayer(spriteLayer)
        }

        popover.behavior = .transient
        popover.delegate = self
        popover.appearance = NSAppearance(named: .aqua)   // the mockup is a light design

        observeStore()
        observeTamer()
        observeDisplaySleep()
        applyState()
    }

    // MARK: Observation

    private func observeStore() {
        withObservationTracking {
            _ = store.menuTitle
            _ = store.menuToolTip
            _ = store.menuLimitColorRuns()
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.applyState()
                self.observeStore()
            }
        }
    }

    /// Menu subject, "!" readiness, sprite downloads and crest events redraw the icon at once,
    /// without waiting for the next usage poll.
    private func observeTamer() {
        withObservationTracking {
            _ = tamer.menuSubject
            _ = tamer.canEvolve
            _ = PartnerMood.current(usage: store, tamer: tamer)
            _ = tamer.state.pendingEvents
            _ = pack.generation
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self else { return }
                self.refreshFrames()
                self.observeTamer()
            }
        }
    }

    private func onStoreRefreshed() {
        pack.reloadIfMissing()   // sprites installed while running show up by the next poll
        tamer.update(todayTokensByProvider: store.todayTokensByProvider,
                     todayDate: LocalUsageReader.todayKey(),
                     hasUsageData: store.hasUsageData)
    }

    private func applyState() {
        guard let button = statusItem.button else { return }
        Self.applyMenuText(store.menuLines, to: button, colors: store.menuLimitColorRuns())
        button.toolTip = store.menuToolTip
        button.appearsDisabled = false
        needsSpriteLayout = true
        refreshFrames()
        if needsSpriteLayout { layoutSpriteLayer() }
    }

    // MARK: Menu bar text (upstream: 1 line, or a vertically centred stack)

    private static func applyMenuText(_ lines: [String], to button: NSStatusBarButton,
                                      colors: [UsageStore.MenuLimitColorRun]) {
        if lines.count >= 2 {
            let thickness = NSStatusBar.system.thickness
            let share = thickness / CGFloat(lines.count)
            let fontSize = min(11, max(8, (share * 0.85).rounded(.down)))
            let lineHeight = min(share, (fontSize * 1.28).rounded())
            let font = NSFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
            func titled(_ offset: CGFloat) -> NSAttributedString {
                let para = NSMutableParagraphStyle()
                para.alignment = .center
                para.minimumLineHeight = lineHeight
                para.maximumLineHeight = lineHeight
                let title = NSMutableAttributedString(
                    string: lines.joined(separator: "\n"),
                    attributes: [.font: font, .paragraphStyle: para, .baselineOffset: offset])
                MenuLimitColoring.apply(colors, to: title)
                return title
            }
            let bounds = button.bounds
            if bounds.height > 1 {
                button.attributedTitle = titled(0)
                let r0 = (button.cell as? NSButtonCell)?.titleRect(forBounds: bounds) ?? bounds
                button.attributedTitle = titled(r0.midY - bounds.midY)
            } else {
                button.attributedTitle = titled(0)
            }
        } else {
            button.attributedTitle = NSAttributedString(string: "")
            let title = lines.first ?? ""
            if !colors.isEmpty, !title.isEmpty {
                let colored = NSMutableAttributedString(
                    string: title,
                    attributes: [.font: button.font ?? NSFont.menuBarFont(ofSize: 0)])
                MenuLimitColoring.apply(colors, to: colored)
                button.attributedTitle = colored
            } else {
                button.title = title
            }
        }
    }

    // MARK: Menu bar sprite

    private var subjectSprite: (path: String?, isEgg: Bool) {
        switch tamer.menuSubject {
        case .none: return (nil, true)
        case .egg(let line): return (tamer.catalog.line(line)?.eggSprite, true)
        case .form(let form): return (tamer.catalog.line(form.line)?.stages[form.stage].sprite, false)
        }
    }

    private var crestEventCount: Int {
        tamer.state.pendingEvents.filter { if case .crestLit = $0 { return true } else { return false } }.count
    }

    private func refreshFrames() {
        let subject = subjectSprite
        let sprite = subject.path.flatMap { pack.sprite($0) }
        let ready = tamer.canEvolve
        let mood = PartnerMood.current(usage: store, tamer: tamer)
        let key = "\(subject.path ?? "-")|\(ready)|\(mood.rawValue)|\(sprite != nil)|\(pack.generation)"

        // A crest that just lit twinkles once next to the character (DESIGN §3.1).
        let crests = crestEventCount
        if crests > lastCrestEvents, let line = tamer.activeLine {
            oneShot = MenuBarArt.crestTwinkle(sprite: sprite, crest: pack.sprite(line.crestSprite))
        }
        lastCrestEvents = crests

        guard key != framesKey || !oneShot.isEmpty else { return }
        framesKey = key
        frames = MenuBarArt.loop(sprite: sprite, isEgg: subject.isEgg, ready: ready, mood: mood)
        frameIndex = 0
        advanceFrame()
    }

    private func advanceFrame() {
        frameTimer?.invalidate()
        frameTimer = nil
        let frame: MenuBarArt.Frame
        if !oneShot.isEmpty {
            frame = oneShot.removeFirst()
        } else {
            guard !frames.isEmpty else { return }
            frame = frames[frameIndex % frames.count]
            frameIndex = (frameIndex + 1) % frames.count
        }
        setStatusImage(frame)
        guard shouldAnimate, frames.count > 1 || !oneShot.isEmpty else { return }
        let timer = Timer(timeInterval: frame.delay, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.advanceFrame() }
        }
        timer.tolerance = frame.delay * 0.1
        RunLoop.main.add(timer, forMode: .common)
        frameTimer = timer
    }

    private var shouldAnimate: Bool {
        displayAwake && !popover.isShown
            && (statusItem.button?.window?.occlusionState.contains(.visible) ?? true)
    }

    private func syncAnimation() {
        if shouldAnimate {
            if frameTimer == nil { advanceFrame() }
        } else {
            frameTimer?.invalidate()
            frameTimer = nil
        }
    }

    private func setStatusImage(_ frame: MenuBarArt.Frame) {
        guard let button = statusItem.button else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer { CATransaction.commit() }
        if placeholderSize != frame.image.size {
            placeholderSize = frame.image.size
            let blank = NSImage(size: frame.image.size)
            button.image = blank
            needsSpriteLayout = true
        }
        spriteLayer.contentsScale = MenuBarArt.scale
        spriteLayer.contents = frame.cgImage
        if needsSpriteLayout { layoutSpriteLayer() }
    }

    private func layoutSpriteLayer() {
        guard let button = statusItem.button, let host = button.layer else { return }
        let bounds = button.bounds
        guard bounds.width > 1, bounds.height > 1 else { return }
        let rect = (button.cell as? NSButtonCell)?.imageRect(forBounds: bounds) ?? bounds
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if spriteLayer.superlayer !== host { host.addSublayer(spriteLayer) }
        spriteLayer.frame = rect
        CATransaction.commit()
        needsSpriteLayout = false
    }

    // MARK: Popover & menu

    @objc private func statusItemClicked() {
        let event = NSApp.currentEvent
        if StatusItemMenu.opensMenu(eventType: event?.type, modifiers: event?.modifierFlags ?? []) {
            showStatusMenu()
        } else if popover.isShown {
            popover.performClose(nil)
        } else {
            showPopover()
        }
    }

    private func showStatusMenu() {
        guard let button = statusItem.button else { return }
        if popover.isShown { popover.performClose(nil) }
        let entries = StatusItemMenu.entries(
            l: tamer.l, notebookTitle: tamer.text.tabNotebook,
            petTitle: store.floatingPetEnabled ? tamer.text.petHide : tamer.text.petShow,
            todayTokens: store.todayTotalTokens,
            todayCost: store.showsCost ? store.todayUsageCost : nil)
        statusItem.menu = StatusItemMenu.build(entries, target: self, selector: #selector(handleStatusMenu(_:)))
        button.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func handleStatusMenu(_ item: NSMenuItem) {
        switch StatusItemMenu.action(of: item) {
        case .refresh: Task { await store.refresh() }
        case .openNotebook: showPopover { $0.tab = .notebook }
        case .openSettings: showPopover { $0.showSettings = true }
        case .toggleFloatingPet: store.floatingPetEnabled.toggle()
        case .quit: NSApp.terminate(nil)
        case nil: break
        }
    }

    private func showPopover(route: (PopoverNavigation) -> Void = { _ in }) {
        guard let button = statusItem.button, !popover.isShown else { return }
        navigation.reset()
        route(navigation)
        pack.reloadIfMissing()
        popover.contentViewController = NSHostingController(
            rootView: PopoverView()
                .environment(store).environment(tamer).environment(navigation).environment(pack))
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKeyAndOrderFront(nil)
        syncAnimation()
        store.requestNotificationAuthorizationIfNeeded()
    }

    func popoverDidShow(_ notification: Notification) {
        outsideClickMonitor.start {
            NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
                Task { @MainActor in
                    guard let self, self.popover.isShown else { return }
                    self.popover.performClose(nil)
                }
            }
        }
    }

    func popoverDidClose(_ notification: Notification) {
        outsideClickMonitor.stop { NSEvent.removeMonitor($0) }
        popover.contentViewController = nil
        syncAnimation()
    }

    // MARK: Notifications & power

    private func postNotification(_ title: String, _ body: String) {
        guard AppEnv.isBundledApp, store.companionNotifications else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }

    private func observeDisplaySleep() {
        let workspace = NSWorkspace.shared.notificationCenter
        workspace.addObserver(forName: NSWorkspace.screensDidSleepNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.setDisplayAwake(false) }
        }
        workspace.addObserver(forName: NSWorkspace.screensDidWakeNotification, object: nil, queue: .main) { [weak self] _ in
            Task { @MainActor in self?.setDisplayAwake(true) }
        }
        NotificationCenter.default.addObserver(
            forName: NSWindow.didChangeOcclusionStateNotification, object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.syncAnimation() }
        }
    }

    private func setDisplayAwake(_ awake: Bool) {
        displayAwake = awake
        syncAnimation()
    }
}
