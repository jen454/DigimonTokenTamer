import SwiftUI

/// Notebook (DESIGN §3.3): one row per line with its crest emblem first — coloured once that
/// crest has shone — then six stage cells. Unseen forms are silhouettes. Clicking a registered
/// form shows it in the menu bar (display form, §2.2); growth is unaffected.
@MainActor
struct NotebookView: View {
    @Environment(TamerStore.self) private var tamer
    @Environment(PopoverNavigation.self) private var nav

    private var t: TamerText { tamer.text }
    private var total: Int { tamer.catalog.lines.count * TamerCatalog.stageCount }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                TamerSectionHeading(title: t.notebookCount(tamer.state.notebook.count, total))
                if tamer.state.displayForm != nil {
                    TextLink(title: t.followPartner, size: 11) { tamer.setDisplayForm(nil) }
                }
            }
            VStack(spacing: 0) {
                ForEach(Array(tamer.catalog.lines.enumerated()), id: \.element.id) { index, line in
                    if index > 0 { Divider().overlay(TamerPalette.nbLine) }
                    row(line)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 4).tamerCard()
            Text(t.notebookHint).font(.system(size: 11)).foregroundStyle(TamerPalette.mute)
        }
    }

    private func row(_ line: TamerCatalog.Line) -> some View {
        let lit = tamer.state.litCrests.contains(line.key)
        return HStack(spacing: 6) {
            PixelSprite(path: line.crestSprite, scale: 1, mode: lit ? .normal : .grey, placeholder: CGSize(width: 24, height: 24))
                .frame(width: 26)
            Text(line.crest.ko)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(lit ? Color(hex: line.crest.color) : Color(hex: "#999999"))
                .frame(width: 28, alignment: .leading)
            // Six equal cells that share the card width, so both edges keep the same margin.
            HStack(spacing: 4) {
                ForEach(0..<TamerCatalog.stageCount, id: \.self) { stage in
                    cell(line, stage)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 6)
    }

    private func cell(_ line: TamerCatalog.Line, _ stage: Int) -> some View {
        let form = FormRef(line: line.key, stage: stage)
        let known = tamer.state.isRegistered(form)
        let isCurrent = tamer.active?.line == line.key && tamer.active?.stage == stage
        let isShown = tamer.state.displayForm == form
        return Button {
            guard known else { return }
            nav.analyzerForm = form
        } label: {
            PixelSprite(path: line.stages[stage].sprite, fit: CGSize(width: 38, height: 34),
                        mode: known ? .normal : .silhouette, placeholder: CGSize(width: 24, height: 24))
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 7).fill(TamerPalette.cell))
                .overlay(RoundedRectangle(cornerRadius: 7)
                    .stroke(isShown ? TamerPalette.orange : (isCurrent ? TamerPalette.link : .clear), lineWidth: 2))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(known ? "\(line.stages[stage].displayName(tamer.language)) · \(tamer.catalog.stageName(stage, tamer.language))" : t.unknownForm)
        .disabled(!known)
    }
}
