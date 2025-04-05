import SwiftUI

struct MarkdownShortcutBar: View {
    @Binding var draftText: String

    var body: some View {
        HStack {
            // 1) Task button
            Button {
                draftText += "- [ ] "
            } label: {
                // iOS uses green; macOS is monochrome
                #if os(iOS)
                Image(systemName: "square")
                    .renderingMode(.template)
                    .foregroundColor(.primary)
                    .help("task")
                #else
                Image(systemName: "square")
                    .help("task")
                #endif
            }

            // 2) Alert button
            Button {
                insertTaskMarker("[!]")
            } label: {
                #if os(iOS)
                Image(systemName: "exclamationmark.triangle")
                    .renderingMode(.template)
                    .foregroundColor(.yellow)
                    .help("alert")
                #else
                Image(systemName: "exclamationmark.triangle")
                    .help("alert")
                #endif
            }

            // [b] red bookmark
            Button {
                insertTaskMarker("[b]")
            } label: {
                #if os(iOS)
                Image(systemName: "bookmark.fill")
                    .renderingMode(.template)
                    .foregroundColor(.red)
                    .help("bookmark")
                #else
                Image(systemName: "bookmark.fill")
                    .help("bookmark")
                #endif
            }

            // [/] partially done green
            Button {
                insertTaskMarker("[/]")
            } label: {
                #if os(iOS)
                Image(systemName: "circle.lefthalf.filled")
                    .renderingMode(.template)
                    .foregroundColor(.green)
                    .help("partially done")
                #else
                Image(systemName: "circle.lefthalf.filled")
                    .help("partially done")
                #endif
            }

            // [i] info blue
            Button {
                insertTaskMarker("[i]")
            } label: {
                #if os(iOS)
                Image(systemName: "info.circle")
                    .renderingMode(.template)
                    .foregroundColor(.blue)
                    .help("info")
                #else
                Image(systemName: "info.circle")
                    .help("info")
                #endif
            }

            // Paste button
            Button {
                handlePaste()
            } label: {
                #if os(iOS)
                Image(systemName: "doc.on.clipboard")
                    .renderingMode(.template)
                    .foregroundColor(.primary)
                    .help("paste")
                #else
                Image(systemName: "doc.on.clipboard")
                    .help("paste")
                #endif
            }

            // Dropdown menu (items are color on iOS, monochrome on macOS)
            Menu {
                // [I] idea orange
                Button {
                    insertTaskMarker("[I]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "lightbulb.fill")
                        .renderingMode(.template)
                        .foregroundColor(.orange)
                    #else
                    Image(systemName: "lightbulb.fill")
                    #endif
                }
                // [<] event gray
                Button {
                    insertTaskMarker("[<]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "calendar")
                        .renderingMode(.template)
                        .foregroundColor(.gray)
                    #else
                    Image(systemName: "calendar")
                    #endif
                }
                // [?] question yellow
                Button {
                    insertTaskMarker("[?]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "questionmark.circle")
                        .renderingMode(.template)
                        .foregroundColor(.yellow)
                    #else
                    Image(systemName: "questionmark.circle")
                    #endif
                }
                // [*] important gold star
                Button {
                    insertTaskMarker("[*]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "star.fill")
                        .renderingMode(.template)
                        .foregroundColor(.yellow)
                    #else
                    Image(systemName: "star.fill")
                    #endif
                }
                // [\"] quotation teal
                Button {
                    insertTaskMarker("[\"]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "quote.bubble")
                        .renderingMode(.template)
                        .foregroundColor(.teal)
                    #else
                    Image(systemName: "quote.bubble")
                    #endif
                }
                // [p] thumbs up green
                Button {
                    insertTaskMarker("[p]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "hand.thumbsup.fill")
                        .renderingMode(.template)
                        .foregroundColor(.green)
                    #else
                    Image(systemName: "hand.thumbsup.fill")
                    #endif
                }
                // [c] thumbs down red
                Button {
                    insertTaskMarker("[c]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "hand.thumbsdown.fill")
                        .renderingMode(.template)
                        .foregroundColor(.red)
                    #else
                    Image(systemName: "hand.thumbsdown.fill")
                    #endif
                }
                // [u] chart up green
                Button {
                    insertTaskMarker("[u]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .renderingMode(.template)
                        .foregroundColor(.green)
                    #else
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    #endif
                }
                // [d] chart down red
                Button {
                    insertTaskMarker("[d]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .renderingMode(.template)
                        .foregroundColor(.red)
                    #else
                    Image(systemName: "chart.line.downtrend.xyaxis")
                    #endif
                }
                // [S] dollar sign green
                Button {
                    insertTaskMarker("[S]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "dollarsign.circle.fill")
                        .renderingMode(.template)
                        .foregroundColor(.green)
                    #else
                    Image(systemName: "dollarsign.circle.fill")
                    #endif
                }
                // [w] Win purple
                Button {
                    insertTaskMarker("[w]")
                } label: {
                    #if os(iOS)
                    Image(systemName: "party.popper")
                        .renderingMode(.template)
                        .foregroundColor(.purple)
                    #else
                    Image(systemName: "party.popper")
                    #endif
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
        .buttonStyle(.borderless)
    }

    // Insert a marker with preceding dash to keep a list style
    private func insertTaskMarker(_ marker: String) {
        draftText += "- \(marker) "
    }

    private func handlePaste() {
        #if canImport(UIKit)
        if let str = UIPasteboard.general.string {
            draftText += str
        }
        #elseif os(macOS)
        if let str = NSPasteboard.general.string(forType: .string) {
            draftText += str
        }
        #endif
    }
}
