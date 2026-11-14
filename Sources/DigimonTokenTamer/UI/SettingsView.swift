import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct SettingsView: View {
    @Environment(UsageStore.self) private var store
    @Environment(TamerStore.self) private var tamer
    @Environment(SpritePack.self) private var pack
    /// 팝오버 내부 화면 전환 방식 — sheet/dismiss 를 쓰지 않는다 (PopoverView 의 NOTE 참조)
    var onClose: () -> Void
    /// 고급 섹션을 펼친 채로 열지. 세션 키 만료 안내에서 들어온 경우에만 true —
    /// 접힌 채로 열면 고칠 입력란이 안 보여 안내가 막다른 길이 된다.
    var startExpanded = false
    @State private var launchAtLogin = LoginItem.isEnabled
    @State private var launchAtLoginError: Error?
    @State private var advancedExpanded = false
    /// startExpanded 를 @State 초기값으로 못 쓴다 — 뷰가 재사용되면 초기화가 다시 안 돌아
    /// 두 번째 진입부터 접힌 채로 열린다. onAppear 에서 1회 반영한다.
    @State private var didApplyStartExpanded = false
    @State private var sessionKeyInput = ""
    /// Pasted keys of the additional accounts, by folder path. Emptied once saved, like the default one.
    @State private var accountSessionKeyInputs: [String: String] = [:]
    @State private var selectedScanProviderID = "claude_code"
    /// Provider the draft currently describes. Picker change updates `selectedScanProviderID`
    /// before the TextField blurs; committing against the selection would write Claude paths
    /// into `customScanRoots.gemini`.
    @State private var customScanDraftOwnerID = "claude_code"
    @State private var customScanDraft = ""
    @State private var customScanMatchCount = 0
    @State private var customScanMatchTask: Task<Void, Never>?
    @State private var customScanMatchGeneration = 0
    @FocusState private var customScanFocused: Bool
    @State private var additionalAccountsDraft = ""
    @FocusState private var additionalAccountsFocused: Bool
    @FocusState private var sessionKeyFocused: Bool
    private var l: L { tamer.l }
    private var t: TamerText { tamer.text }

    private var isBundledApp: Bool { AppEnv.isBundledApp }

    /// 현재 앱 버전 — 업데이트 적용 여부 확인용으로 설정창 하단에 표기.
    private static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
    }

    // MARK: 레이아웃 — 헤더 고정 / 본문 스크롤 / 푸터 고정

    var body: some View {
        @Bindable var store = store
        VStack(spacing: 0) {
            header
            Divider()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        generalGroup(store)
                        displayFormGroup
                        menuBarGroup(store)
                        notificationsGroup(store)
                        spritePackGroup
                        advancedGroup(store)
                            .id("advancedSettingsSection")
                        aboutSupportGroup
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onAppear {
                    guard !didApplyStartExpanded else { return }
                    didApplyStartExpanded = true
                    if startExpanded {
                        advancedExpanded = true
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 80_000_000)
                            // Initial navigation must reveal the repair field without waiting for an animation.
                            proxy.scrollTo("advancedSettingsSection", anchor: .top)
                            sessionKeyFocused = true
                        }
                    }
                }
            }
            Divider()
            footer
        }
        .frame(height: 640)
    }

    private var header: some View {
        HStack(spacing: 6) {
            Button(action: onClose) {
                HStack(spacing: 2) {
                    Image(systemName: "chevron.backward")
                    Text(l.back)
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
            .keyboardShortcut(.cancelAction)
            Spacer()
            Text(l.settings).font(.headline)
            Spacer()
            // 좌측 뒤로 버튼과 시각적 균형 (제목 중앙 정렬 유지)
            Text(l.back).opacity(0).accessibilityHidden(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private var footer: some View {
        HStack(spacing: 5) {
            Text("v\(Self.appVersion)")
            Text("·")
            footerLink("DigiMonTokenBar", "https://github.com/Choisiz/DigiMonTokenBar")
            Text("·")
            footerLink("PokeTokenBar", "https://github.com/chattymin/PokeTokenBar")
            Text("·")
            Text(t.notice).lineLimit(1).minimumScaleFactor(0.8)
            Spacer()
        }
        .font(.caption2)
        .foregroundStyle(CyberPalette.muted.opacity(0.85))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: 그룹 섹션

    @ViewBuilder
    private func generalGroup(_ store: UsageStore) -> some View {
        @Bindable var store = store
        settingsSection(l.generalSectionTitle) {
            groupRow {
                Text(l.language)
                Spacer()
                Picker(l.language, selection: Binding(
                    get: { tamer.language },
                    set: { tamer.setLanguage($0); store.localizationLanguage = $0 })) {
                    ForEach(AppLanguage.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .labelsHidden().pickerStyle(.menu).fixedSize()
            }
            Divider()
            groupRow {
                Text(l.refreshInterval)
                Spacer()
                Picker(l.refreshInterval, selection: $store.refreshInterval) {
                    ForEach(UsageStore.intervalPresets, id: \.value) { Text(l.intervalLabel($0.value)).tag($0.value) }
                }
                .labelsHidden().pickerStyle(.menu).fixedSize()
            }
            Divider()
            groupRow {
                // 메뉴바 스프라이트와 플로팅 펫 **둘 다**에 적용되므로 펫 섹션이 아니라 일반 섹션에 둔다.
                VStack(alignment: .leading, spacing: 1) {
                    Text(l.animationQualityLabel)
                    Text(l.animationQualityHint).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                }
                Spacer()
                Picker(l.animationQualityLabel, selection: $store.animationQuality) {
                    Text(l.animationPowerSaver).tag(UsageStore.AnimationQuality.powerSaver)
                    Text(l.animationBalanced).tag(UsageStore.AnimationQuality.balanced)
                    Text(l.animationSmooth).tag(UsageStore.AnimationQuality.smooth)
                }
                .labelsHidden().pickerStyle(.menu).fixedSize()
            }
            Divider()
            groupRow {
                Text(l.limitDisplayModeLabel)
                Spacer()
                Picker(l.limitDisplayModeLabel, selection: $store.limitDisplayMode) {
                    Text(l.limitDisplayUsed).tag(UsageStore.LimitDisplayMode.used)
                    Text(l.limitDisplayRemaining).tag(UsageStore.LimitDisplayMode.remaining)
                }
                .labelsHidden().pickerStyle(.segmented).fixedSize()
            }
            if store.claudeAccounts.count > 1 {
                Divider()
                trackedAccountRow(store)
            }
            Divider()
            groupRow {
                VStack(alignment: .leading, spacing: 1) {
                    Text(l.launchAtLogin)
                    if !isBundledApp {
                        Text(l.bundledOnly).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                    }
                    if let launchAtLoginError {
                        Text(l.userFacingError(launchAtLoginError)).font(.caption2).foregroundStyle(.red)
                    }
                }
                Spacer()
                Toggle(l.launchAtLogin, isOn: $launchAtLogin)
                    .labelsHidden().toggleStyle(.switch).controlSize(.small)
                    .disabled(!isBundledApp)
                    .onChange(of: launchAtLogin) { _, newValue in
                        do {
                            try LoginItem.setEnabled(newValue)   // KeepAlive 에이전트(로그인 실행+크래시 재실행)
                            launchAtLoginError = nil
                        } catch {
                            AppLog.write("login item update failed: \(error)")
                            launchAtLoginError = error
                            launchAtLogin = LoginItem.isEnabled
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private func menuBarGroup(_ store: UsageStore) -> some View {
        @Bindable var store = store
        VStack(alignment: .leading, spacing: 6) {
            settingsSection(l.menuBarSectionTitle) {
                toggleRow(l.todayTokensShort, $store.showTokensInMenu)
                Divider()
                toggleRow(l.todayCost, $store.showCostInMenu)
                Divider()
                toggleRow(l.limitPercent, $store.showLimitInMenu)
                if store.showLimitInMenu {
                    Divider()
                    groupRow {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(l.menuLimitColor)
                            Text(l.menuLimitColorHint).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                        }
                        Spacer()
                        Picker(l.menuLimitColor, selection: $store.menuLimitColorMode) {
                            ForEach(UsageStore.MenuLimitColorMode.allCases, id: \.self) {
                                Text(l.menuLimitColorMode($0)).tag($0)
                            }
                        }
                        .labelsHidden()
                        .fixedSize()
                    }
                }
            }
            Text(l.allOffHint).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85)).padding(.leading, 4)
        }
    }

    @ViewBuilder
    private func notificationsGroup(_ store: UsageStore) -> some View {
        @Bindable var store = store
        settingsSection(l.notificationsSection) {
            toggleRow(l.limitNotificationsLabel, $store.limitNotifications)
            if store.limitNotifications {
                Divider()
                groupRow {
                    Text(l.warning).font(.callout)
                    Slider(value: $store.warnThreshold, in: 50...95, step: 5)
                        .accessibilityLabel(l.warning)
                    Text(TokenFormatter.percent(store.warnThreshold))
                        .font(.caption).monospacedDigit().frame(width: 38, alignment: .trailing)
                }
                Divider()
                groupRow {
                    Text(l.critical).font(.callout)
                    Slider(value: $store.critThreshold, in: 80...100, step: 5)
                        .accessibilityLabel(l.critical)
                    Text(TokenFormatter.percent(store.critThreshold))
                        .font(.caption).monospacedDigit().frame(width: 38, alignment: .trailing)
                }
            }
            Divider()
            toggleRow(l.companionNotificationsLabel, $store.companionNotifications)
            Divider()
            groupRow {
                VStack(alignment: .leading, spacing: 1) {
                    Text(l.statusChecksLabel)
                    Text(l.statusChecksHint).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                }
                Spacer()
                Toggle(l.statusChecksLabel, isOn: $store.statusChecksEnabled)
                    .labelsHidden().toggleStyle(.switch).controlSize(.small)
            }
        }
    }

    /// claude.ai 세션 키 — Keychain 을 안 읽는 한도 조회 경로. 붙여넣고 저장하면 즉시 검증한다.
    @ViewBuilder
    private func sessionKeyRows(_ store: UsageStore) -> some View {
        groupRow {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(l.sessionKeyLabel)
                    if store.sessionKeyExpired {
                        // 키는 아직 저장돼 있지만 서버가 거부한 상태 — 여기서 '설정됨' 을 그대로
                        // 두면 만료 안내를 보고 들어온 사용자가 할 일을 못 찾는다.
                        Text(l.sessionKeyExpiredBadge)
                            .font(.caption2).foregroundStyle(.orange)
                    } else if store.sessionKeyConfigured {
                        Text(l.sessionKeySaved)
                            .font(.caption2).foregroundStyle(.green)
                    }
                }
                // The key only replaces the default login's Keychain read; other accounts have their own below.
                Text(store.additionalClaudeConfigRoots.isEmpty ? l.sessionKeyHint : l.sessionKeyHint + " " + l.sessionKeyPerAccountNote)
                    .font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        groupRow {
            // 값은 되돌려 보여주지 않는다 — 저장돼 있으면 빈 칸에 자리표시만 둔다.
            SecureField(store.sessionKeyConfigured ? "••••••••" : "sk-ant-sid…", text: $sessionKeyInput)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 220)
                .focused($sessionKeyFocused)
                .onSubmit { submitSessionKey(store) }
            Button {
                submitSessionKey(store)
            } label: {
                if store.isValidatingSessionKey {
                    ProgressView().controlSize(.small)
                } else {
                    Text(l.save)
                }
            }
            .disabled(sessionKeyInput.isEmpty || store.isValidatingSessionKey)
            if store.sessionKeyConfigured {
                Button(l.delete) {
                    sessionKeyInput = ""
                    store.clearSessionKey()
                }
            }
            Spacer()
        }
        // 조직이 여럿일 때만 노출 — 자동 선택이 개인/회사 계정을 잘못 고를 수 있다.
        if store.sessionKeyOrganizations.count > 1 {
            groupRow {
                Text(l.sessionKeyOrganizationLabel)
                Spacer()
                Picker(l.sessionKeyOrganizationLabel, selection: Binding(
                    get: { store.sessionKeySelectedOrgID ?? "" },
                    set: { id in Task { await store.selectSessionOrganization(id) } })
                ) {
                    ForEach(store.sessionKeyOrganizations) { org in
                        Text(org.name).tag(org.id)
                    }
                }
                .labelsHidden().frame(maxWidth: 220)
            }
        }
        if let sessionKeyError = store.sessionKeyError {
            Text(sessionKeyError)
                .font(.caption2).foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12).padding(.bottom, 6)
        } else if store.sessionKeyConfigured {
            Text(l.sessionKeyStorageNote)
                .font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12).padding(.bottom, 6)
        }
    }

    /// Each additional Claude folder can have its own key. Without one, its limits come from its
    /// Keychain token, which automatic polls never read: they stop whenever that token expires.
    @ViewBuilder
    private func accountSessionKeyRows(_ store: UsageStore) -> some View {
        ForEach(store.additionalClaudeConfigRoots, id: \.self) { rootPath in
            Divider()
            accountSessionKeyRow(store, rootPath: rootPath)
        }
        // The storage note is shown once, under the default key when that one is saved.
        if !store.accountSessionKeyPaths.isEmpty, !store.sessionKeyConfigured || store.sessionKeyError != nil {
            Text(l.sessionKeyStorageNote)
                .font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12).padding(.bottom, 6)
        }
    }

    @ViewBuilder
    private func accountSessionKeyRow(_ store: UsageStore, rootPath: String) -> some View {
        let folder = (rootPath as NSString).abbreviatingWithTildeInPath
        let account = store.claudeAccounts.first {
            $0.id == ClaudeAccountRoots.pathKey(for: URL(fileURLWithPath: rootPath))
        }
        let title = account?.title ?? folder
        let configured = store.accountSessionKeyPaths.contains(rootPath)
        let input = Binding(get: { accountSessionKeyInputs[rootPath] ?? "" },
                            set: { accountSessionKeyInputs[rootPath] = $0 })
        groupRow {
            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 6) {
                    Text(l.accountSessionKeyLabel(title))
                    if account?.sessionKeyExpired == true {
                        Text(l.sessionKeyExpiredBadge)
                            .font(.caption2).foregroundStyle(.orange)
                    } else if configured {
                        Text(l.sessionKeySaved)
                            .font(.caption2).foregroundStyle(.green)
                    }
                }
                // The email names the browser login to copy the key from; the folder tells two logins apart.
                if title != folder {
                    Text(folder).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                }
            }
            Spacer()
        }
        groupRow {
            SecureField(configured ? "••••••••" : "sk-ant-sid…", text: input)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 220)
                .onSubmit { submitAccountSessionKey(store, rootPath: rootPath) }
            Button {
                submitAccountSessionKey(store, rootPath: rootPath)
            } label: {
                if store.validatingAccountSessionKeyPath == rootPath {
                    ProgressView().controlSize(.small)
                } else {
                    Text(l.save)
                }
            }
            .disabled(input.wrappedValue.isEmpty || store.validatingAccountSessionKeyPath != nil)
            if configured {
                Button(l.delete) {
                    accountSessionKeyInputs[rootPath] = nil
                    store.clearAccountSessionKey(for: rootPath)
                }
            }
            Spacer()
        }
        if let error = store.accountSessionKeyError(for: rootPath) {
            Text(error)
                .font(.caption2).foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12).padding(.bottom, 6)
        }
    }

    private func submitAccountSessionKey(_ store: UsageStore, rootPath: String) {
        guard let pasted = accountSessionKeyInputs[rootPath], !pasted.isEmpty else { return }
        Task {
            await store.saveAccountSessionKey(pasted, for: rootPath)
            if store.accountSessionKeyError(for: rootPath) == nil { accountSessionKeyInputs[rootPath] = nil }
        }
    }

    private func submitSessionKey(_ store: UsageStore) {
        let pasted = sessionKeyInput
        guard !pasted.isEmpty else { return }
        Task {
            await store.saveSessionKey(pasted)
            // 저장에 성공했으면 입력칸을 비운다(키가 화면에 남아있지 않게). 실패면 고쳐 넣을 수 있게 남긴다.
            if store.sessionKeyError == nil { sessionKeyInput = "" }
        }
    }

    @ViewBuilder
    private func advancedGroup(_ store: UsageStore) -> some View {
        @Bindable var store = store
        settingsSection(l.advancedSectionTitle) {
            Button {
                withAnimation(.easeInOut(duration: 0.15)) { advancedExpanded.toggle() }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.forward")
                        .font(.caption).foregroundStyle(CyberPalette.muted)
                        .rotationEffect(.degrees(advancedExpanded ? 90 : 0))
                    Text(l.advancedDisclosureLabel)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12).padding(.vertical, 9)
            .onChange(of: advancedExpanded) { _, expanded in
                if !expanded {
                    commitCustomScanDraft()
                    customScanMatchTask?.cancel()
                }
            }

            if advancedExpanded {
                Divider()
                sessionKeyRows(store)
                    // 재시작 후엔 후보 목록이 비어 있어 조직을 바꿀 수 없다 — 열 때 한 번 채운다.
                    .task { await store.refreshSessionOrganizations() }
                accountSessionKeyRows(store)
                Divider()
                groupRow {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(l.disableKeychain)
                        Text(l.disableKeychainHint).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                    }
                    Spacer()
                    Toggle(l.disableKeychain, isOn: $store.disableKeychainAccess)
                        .labelsHidden().toggleStyle(.switch).controlSize(.small)
                }
                Divider()
                groupRow {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(l.refreshLimitToken)
                        Text(l.onlyOnPress).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                    }
                    Spacer()
                    Button {
                        Task { await store.refreshLimitTokenFromKeychain() }
                    } label: {
                        if store.isRefreshingLimitToken {
                            ProgressView().controlSize(.small)
                        } else {
                            Text(l.refreshLimitToken)
                        }
                    }
                    .disabled(store.disableKeychainAccess || store.isRefreshingLimitToken)
                }
                if let message = store.limitTokenRefreshMessage {
                    Text(message)
                        .font(.caption2).foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12).padding(.bottom, 6)
                }
                Divider()
                additionalAccountsRow(store)
                Divider()
                groupRow {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(l.customScanRootsLabel)
                        Text(l.customScanRootsHint).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                        HStack {
                            Text(l.customScanProviderLabel).font(.caption)
                            Spacer()
                            Picker(l.customScanProviderLabel, selection: $selectedScanProviderID) {
                                ForEach(store.registeredProviders, id: \.id) { provider in
                                    Text(provider.displayName).tag(provider.id)
                                }
                            }
                            .labelsHidden().pickerStyle(.menu).fixedSize()
                        }
                        TextField(l.customScanRootsPlaceholder, text: $customScanDraft, axis: .vertical)
                            .textFieldStyle(.roundedBorder).font(.caption)
                            .focused($customScanFocused)
                            .onSubmit { commitCustomScanDraft() }
                        if !customScanDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(l.customScanRootsMatches(customScanMatchCount))
                                .font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                        }
                    }
                }
                .onAppear {
                    customScanDraftOwnerID = selectedScanProviderID
                    customScanDraft = store.customScanRoots(for: selectedScanProviderID)
                    scheduleCustomScanMatchCount()
                }
                .onDisappear {
                    commitCustomScanDraft()
                    customScanMatchTask?.cancel()
                }
                .onChange(of: selectedScanProviderID) { _, newID in
                    store.setCustomScanRoots(customScanDraft, for: customScanDraftOwnerID)
                    customScanDraftOwnerID = newID
                    customScanDraft = store.customScanRoots(for: newID)
                    scheduleCustomScanMatchCount()
                }
                .onChange(of: customScanDraft) { _, _ in
                    scheduleCustomScanMatchCount()
                }
                .onChange(of: customScanFocused) { _, focused in
                    if !focused { commitCustomScanDraft() }
                }
                Divider()
                Text(l.aggregationNote)
                    .font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                    .padding(.horizontal, 12).padding(.vertical, 8)
            }
        }
    }

    /// Only shown with several Claude accounts. The default account is listed under its own title.
    private func trackedAccountRow(_ store: UsageStore) -> some View {
        let accountModes = store.claudeAccounts.map {
            (account: $0, mode: $0.isDefault ? ClaudeTrackedAccountMode.defaultAccount : .account($0.id))
        }
        // A pinned account that is gone falls back to automatic (`UsageStore.trackedAccount`): show that.
        let selection = Binding(
            get: {
                let mode = store.claudeTrackedAccountMode
                return accountModes.contains { $0.mode == mode } || mode == .highest ? mode : .automatic
            },
            set: { store.claudeTrackedAccountMode = $0 })
        // Stacked: account emails make the picker too wide to sit next to the label.
        return groupRow {
            VStack(alignment: .leading, spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(l.trackedAccountLabel)
                    Text(l.trackedAccountHint).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                }
                HStack {
                    Spacer()
                    Picker(l.trackedAccountLabel, selection: selection) {
                        Text(l.trackedAccountAutomatic).tag(ClaudeTrackedAccountMode.automatic)
                        Text(l.trackedAccountHighest).tag(ClaudeTrackedAccountMode.highest)
                        ForEach(accountModes, id: \.account.id) { item in
                            Text(item.account.title).tag(item.mode)
                        }
                    }
                    .labelsHidden().pickerStyle(.menu).fixedSize()
                }
            }
        }
    }

    /// Detected and extra Claude config folders; each account gets its own tab in the popover's official limits.
    /// Committed on submit / focus loss, like the custom scan folders: each commit triggers a refresh.
    private func additionalAccountsRow(_ store: UsageStore) -> some View {
        groupRow {
            VStack(alignment: .leading, spacing: 6) {
                Text(l.additionalClaudeAccountsLabel)
                Text(l.additionalClaudeAccountsHint).font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                if !store.detectedClaudeConfigDirs.isEmpty {
                    Text(l.additionalClaudeAccountsDetected(store.detectedClaudeConfigDirs
                        .map { ($0 as NSString).abbreviatingWithTildeInPath }
                        .joined(separator: ", ")))
                        .font(.caption2).foregroundStyle(CyberPalette.muted)
                }
                TextField(l.additionalClaudeAccountsPlaceholder, text: $additionalAccountsDraft, axis: .vertical)
                    .textFieldStyle(.roundedBorder).font(.caption)
                    .focused($additionalAccountsFocused)
                    .onSubmit { store.additionalClaudeConfigDirs = additionalAccountsDraft }
                if !additionalAccountsDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(l.additionalClaudeAccountsFound(ClaudeAccountRoots.roots(from: additionalAccountsDraft).count))
                        .font(.caption2).foregroundStyle(CyberPalette.muted.opacity(0.85))
                }
            }
        }
        .onAppear { additionalAccountsDraft = store.additionalClaudeConfigDirs }
        .onDisappear { store.additionalClaudeConfigDirs = additionalAccountsDraft }
        .onChange(of: additionalAccountsFocused) { _, focused in
            if !focused { store.additionalClaudeConfigDirs = additionalAccountsDraft }
        }
    }

    private var aboutSupportGroup: some View {
        settingsSection(l.aboutSupportSectionTitle) {
            // 로그 파일 보기 — 문제 제보 시 바로 첨부할 수 있게 같은 그룹에 둔다(고급 접기 밖).
            groupRow {
                Text(l.showLogFile)
                Spacer()
                Button("Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([AppLog.logFileURL])
                }
            }
        }
    }

    // MARK: Tamer

    /// DESIGN §2.2: any registered form can be shown in the menu bar; growth is unchanged.
    private var displayFormGroup: some View {
        settingsSection(t.displayFormTitle) {
            groupRow {
                Text(t.displayFormTitle)
                Spacer()
                Picker(t.displayFormTitle, selection: Binding(
                    get: { tamer.state.displayForm?.key ?? "" },
                    set: { key in tamer.setDisplayForm(registeredForms.first { $0.key == key }) })) {
                    Text(t.followPartner).tag("")
                    ForEach(registeredForms, id: \.key) { form in
                        Text(formLabel(form)).tag(form.key)
                    }
                }
                .labelsHidden().pickerStyle(.menu).fixedSize()
            }
            Text(t.displayFormHint).font(.caption2).foregroundStyle(TamerPalette.mute)
                .padding(.horizontal, 12).padding(.bottom, 8)
        }
    }

    private var registeredForms: [FormRef] {
        tamer.catalog.lines.flatMap { line in
            (0..<TamerCatalog.stageCount).map { FormRef(line: line.key, stage: $0) }
        }.filter { tamer.state.isRegistered($0) }
    }

    private func formLabel(_ form: FormRef) -> String {
        guard let line = tamer.catalog.line(form.line) else { return form.key }
        return "\(line.stages[form.stage].name) · \(tamer.catalog.stageName(form.stage, tamer.language))"
    }

    /// DESIGN §5.2: artwork is not bundled. Shows where it is read from and how much was found.
    private var spritePackGroup: some View {
        @Bindable var pack = pack
        let paths = SpritePack.allPaths(tamer.catalog)
        let found = pack.availability(of: paths)
        return settingsSection(t.spritePackTitle) {
            groupRow {
                VStack(alignment: .leading, spacing: 1) {
                    Text(t.spritePackStatus(found, paths.count))
                    if found < paths.count {
                        Text(t.spritePackMissing).font(.caption2).foregroundStyle(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
                Button(t.reloadSprites) { pack.reload() }.controlSize(.small)
                Button(t.openSpriteFolder) {
                    try? FileManager.default.createDirectory(at: SpritePack.installDirectory, withIntermediateDirectories: true)
                    NSWorkspace.shared.open(SpritePack.installDirectory)
                }.controlSize(.small)
            }
            Divider()
            groupRow {
                Text(t.spritePackURL)
                Spacer()
                TextField("https://…", text: $pack.baseURL)
                    .textFieldStyle(.roundedBorder).font(.caption).frame(width: 190)
            }
        }
    }

    // MARK: 공용 빌더

    /// 섹션 = 소문자 회색 타이틀 + 라운드 카드 (macOS inset grouped 룩).
    @ViewBuilder
    private func settingsSection<Content: View>(
        _ title: String, @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption).fontWeight(.semibold).foregroundStyle(CyberPalette.cyan)
                .textCase(.uppercase).padding(.leading, 4)
            VStack(spacing: 0) { content() }
                .tamerCard(radius: 10)
        }
    }

    /// 카드 내부 한 줄 — 좌 라벨 / 우 컨트롤.
    private func groupRow<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 10) { content() }
            .padding(.horizontal, 12).padding(.vertical, 8)
            .frame(minHeight: 38)
    }

    private func toggleRow(_ label: String, _ isOn: Binding<Bool>) -> some View {
        groupRow {
            Text(label)
            Spacer()
            Toggle(label, isOn: isOn).labelsHidden().toggleStyle(.switch).controlSize(.small)
        }
    }

    /// 푸터 링크 — 버전 표기와 동일한 크기·색을 상속하고 밑줄로만 구분.
    private func footerLink(_ title: String, _ urlString: String) -> some View {
        Button {
            if let url = URL(string: urlString) { NSWorkspace.shared.open(url) }
        } label: {
            Text(title).underline()
        }
        .buttonStyle(.plain)
        .help(urlString)
    }

    private func commitCustomScanDraft() {
        store.setCustomScanRoots(customScanDraft, for: customScanDraftOwnerID)
    }

    private func scheduleCustomScanMatchCount() {
        customScanMatchTask?.cancel()
        customScanMatchGeneration += 1
        let generation = customScanMatchGeneration
        let raw = customScanDraft
        let providerID = selectedScanProviderID
        customScanMatchTask = Task.detached(priority: .utility) {
            try? await Task.sleep(nanoseconds: 250_000_000)
            guard !Task.isCancelled else { return }
            let count = CustomScanRoots.survivingExtraCount(
                defaults: CustomScanRoots.curatedRoots(for: providerID),
                extraRaw: raw)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard generation == customScanMatchGeneration else { return }
                customScanMatchCount = count
            }
        }
    }

    // MARK: 동작
}
