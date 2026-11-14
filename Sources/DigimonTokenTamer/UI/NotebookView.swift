import SwiftUI

/// Notebook (DESIGN §3.3): one row per line with its crest emblem first — coloured once that
/// crest has shone — then six stage cells. Unseen forms are silhouettes. Clicking a registered
/// form shows it in the menu bar (display form, §2.2); growth is unaffected.
@MainActor
struct NotebookView: View {
    @Environment(TamerStore.self) private var tamer

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
        return HStack(spacing: 8) {
            PixelSprite(path: line.crestSprite, scale: 1, mode: lit ? .normal : .grey, placeholder: CGSize(width: 24, height: 24))
                .frame(width: 28)
            Text(line.crest.ko)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(lit ? Color(hex: line.crest.color) : Color(hex: "#999999"))
                .frame(width: 30, alignment: .leading)
            HStack(spacing: 5) {
                ForEach(0..<TamerCatalog.stageCount, id: \.self) { stage in
                    cell(line, stage)
                }
            }
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
            tamer.setDisplayForm(isShown ? nil : form)
        } label: {
            PixelSprite(path: line.stages[stage].sprite, fit: CGSize(width: 40, height: 36),
                        mode: known ? .normal : .silhouette, placeholder: CGSize(width: 24, height: 24))
                .frame(width: 46, height: 42, alignment: .bottom)
                .padding(.bottom, 2)
                .background(RoundedRectangle(cornerRadius: 7).fill(TamerPalette.cell))
                .overlay(RoundedRectangle(cornerRadius: 7)
                    .stroke(isShown ? TamerPalette.orange : (isCurrent ? TamerPalette.link : .clear), lineWidth: 2))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(known ? "\(line.stages[stage].name) · \(tamer.catalog.stageName(stage, tamer.language))" : t.unknownForm)
        .disabled(!known)
    }
}
