import AppKit
import SwiftUI

/// Notebook detail page, titled 아날라이저 after Koushiro's Digimon Analyzer. Laid out like
/// DigiMonTokenBar's dex detail: a large sprite, the name, the profile facts (level, type,
/// attribute, moves) and a link to the official reference. The official profile text itself is
/// not copied (copyright); the evolution route and the line's crest take its place.
@MainActor
struct AnalyzerView: View {
    @Environment(TamerStore.self) private var tamer
    @Environment(SpritePack.self) private var pack
    let form: FormRef
    let onBack: () -> Void

    private var t: TamerText { tamer.text }

    var body: some View {
        if let line = tamer.catalog.line(form.line), line.stages.indices.contains(form.stage) {
            content(line, line.stages[form.stage])
        }
    }

    private func content(_ line: TamerCatalog.Line, _ stage: TamerCatalog.Stage) -> some View {
        let lang = tamer.language
        let crestColor = Color(hex: line.crest.color)
        return VStack(alignment: .leading, spacing: 12) {
            // Title bar: back to the notebook, "아날라이저" in the middle.
            ZStack {
                Text(t.analyzerTitle).font(.system(size: 14, weight: .bold))
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 2) {
                            Image(systemName: "chevron.backward")
                            Text(t.back)
                        }
                        .font(.system(size: 12))
                        .foregroundStyle(TamerPalette.link)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut(.cancelAction)
                    Spacer()
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                // Large sprite
                ZStack(alignment: .bottom) {
                    LinearGradient(colors: [TamerPalette.stageTop, TamerPalette.stageBottom], startPoint: .top, endPoint: .bottom)
                    let pixels = pack.sprite(stage.sprite)?.pixels ?? CGSize(width: 40, height: 40)
                    let scale = max(1, min(4, (150 / max(pixels.width, pixels.height)).rounded(.down)))
                    MotionSprite(path: stage.sprite, scale: scale, mood: .idle)
                        .padding(.bottom, 10)
                }
                .frame(height: 170)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                // Name
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(stage.displayName(lang)).font(.system(size: 20, weight: .bold))
                        if lang == .ko { Text(stage.name).font(.system(size: 12)).foregroundStyle(TamerPalette.mute) }
                        Spacer()
                        Text("\(t.lineLabel(line.ko, line.key)) · \(tamer.catalog.stageName(form.stage, lang))")
                            .font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
                    }
                    if stage.koUnverified == true, lang == .ko {
                        Text(t.analyzerNameNote).font(.system(size: 10)).foregroundStyle(TamerPalette.mute)
                    }
                }

                // Profile facts
                VStack(alignment: .leading, spacing: 6) {
                    sectionTitle(t.analyzerProfile)
                    factRow(t.analyzerStage, tamer.catalog.stageName(form.stage, lang))
                    if let info = stage.info {
                        factRow(t.analyzerType, info.type.text(lang))
                        let attribute = info.attribute.text(lang)
                        factRow(t.analyzerAttribute, attribute.isEmpty ? t.analyzerNoAttribute : attribute)
                        let moves = info.moves.list(lang)
                        if !moves.isEmpty {
                            HStack(alignment: .top, spacing: 10) {
                                Text(t.analyzerMoves).foregroundStyle(TamerPalette.mute).frame(width: 52, alignment: .leading)
                                WrappingHStack(spacing: 4, lineSpacing: 4) {
                                    ForEach(moves, id: \.self) { move in
                                        Text(move)
                                            .padding(.horizontal, 7).padding(.vertical, 2)
                                            .foregroundStyle(crestColor)
                                            .overlay(Capsule().stroke(crestColor.opacity(0.5), lineWidth: 1))
                                            .fixedSize()
                                    }
                                }
                            }
                            .font(.system(size: 12))
                        }
                        if let url = info.source.flatMap({ URL(string: $0.text(lang)) }) {
                            TextLink(title: t.analyzerOfficial, size: 11) { NSWorkspace.shared.open(url) }
                                .padding(.top, 2)
                        }
                    } else {
                        Text(t.analyzerNoOfficial).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
                    }
                }

                Divider().overlay(TamerPalette.nbLine)

                // Evolution route: the line's six forms, the condition to reach each under it.
                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle(t.analyzerRoute)
                    HStack(alignment: .top, spacing: 2) {
                        ForEach(0..<TamerCatalog.stageCount, id: \.self) { index in
                            if index > 0 {
                                Image(systemName: "chevron.right").font(.system(size: 8)).foregroundStyle(TamerPalette.mute)
                                    .padding(.top, 18)
                            }
                            routeCell(line, index)
                        }
                    }
                }

                Divider().overlay(TamerPalette.nbLine)

                // Crest of the line
                HStack(spacing: 10) {
                    let lit = tamer.state.litCrests.contains(line.key)
                    PixelSprite(path: line.crestSprite, scale: 1, mode: lit ? .normal : .grey, placeholder: CGSize(width: 24, height: 24))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(t.crestName(line.crest.ko, en: line.crest.en)).font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(lit ? crestColor : TamerPalette.ink)
                        Text(lit ? t.crestLitState : t.crestDimState).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
                    }
                    Spacer()
                    let shown = tamer.state.displayForm == form
                    Button(shown ? t.shownInMenuBar : t.showInMenuBar) {
                        tamer.setDisplayForm(shown ? nil : form)
                    }
                    .buttonStyle(.bordered).controlSize(.small)
                }
            }
            .padding(14)
            .tamerCard()
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title).font(.system(size: 11, weight: .semibold)).foregroundStyle(TamerPalette.mute)
    }

    private func factRow(_ label: String, _ value: String) -> some View {
        HStack(spacing: 10) {
            Text(label).foregroundStyle(TamerPalette.mute).frame(width: 52, alignment: .leading)
            Text(value).foregroundStyle(TamerPalette.ink)
            Spacer(minLength: 0)
        }
        .font(.system(size: 12))
    }

    private func routeCell(_ line: TamerCatalog.Line, _ index: Int) -> some View {
        let ref = FormRef(line: line.key, stage: index)
        let known = tamer.state.isRegistered(ref)
        let selected = index == form.stage
        return VStack(spacing: 3) {
            Button {
                if known { tamerOpen(ref) }
            } label: {
                PixelSprite(path: line.stages[index].sprite, fit: CGSize(width: 34, height: 30),
                            mode: known ? .normal : .silhouette, placeholder: CGSize(width: 20, height: 20))
                    .frame(width: 44, height: 38)
                    .background(RoundedRectangle(cornerRadius: 6).fill(TamerPalette.cell))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(selected ? TamerPalette.orange : .clear, lineWidth: 2))
            }
            .buttonStyle(.plain)
            .disabled(!known)
            Text(known ? line.stages[index].displayName(tamer.language) : "???")
                .font(.system(size: 9)).lineLimit(1).minimumScaleFactor(0.6)
                .frame(width: 48)
            Text(t.routeCondition(index)).font(.system(size: 8)).foregroundStyle(TamerPalette.mute)
                .lineLimit(1).minimumScaleFactor(0.6).frame(width: 48)
        }
    }

    @Environment(PopoverNavigation.self) private var nav
    private func tamerOpen(_ ref: FormRef) { nav.analyzerForm = ref }
}
