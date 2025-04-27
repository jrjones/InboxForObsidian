import SwiftUI
import SwiftData
import Foundation
import MarkdownUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @FocusState private var isTextEditorFocused: Bool

    @StateObject private var viewModel: InboxViewModel
    @State private var isPreview: Bool = false

    /// Inject the ModelContext from the app for SwiftData operations.
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: InboxViewModel(context: modelContext))
    }

    var body: some View {
        VStack {
            // Editor / Preview toggle
            Group {
            if isPreview {
                // Render Markdown with task previews using TaskMarkdownPreview
                ScrollView {
                    TaskMarkdownPreview(markdown: viewModel.draftText)
                        .padding(.horizontal, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            } else {
#if canImport(UIKit)
                    PasteHandlingTextEditor(text: $viewModel.draftText)
#else
                    PasteHandlingTextEditor(text: $viewModel.draftText,
                                             isFocused: $isTextEditorFocused)
#endif
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Shortcut bar inset
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    MarkdownShortcutBar(draftText: $viewModel.draftText, showsSyncButton: false) {
                        Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(.thinMaterial)
            }
        }
#if os(visionOS)
        // Vision‑only ornament toolbar
        .ornament(
            attachmentAnchor: .scene(.leading),
            contentAlignment: .leading
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    viewModel.startNewDraft()
                    isTextEditorFocused = true
                } label: {
                    Image(systemName: "plus.circle")
                }
                Button {
                    isPreview.toggle()
                } label: {
                    Image(systemName: isPreview ? "pencil" : "eye")
                }
                Button {
                    Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
            .padding()
            .background(.thinMaterial)
            .cornerRadius(20)
            .offset(x: -30)
        }
#endif
        // Standard toolbar for non‑visionOS
        .toolbar {
#if !os(visionOS)
            ToolbarItem {
                HStack {
                    Button {
                        viewModel.startNewDraft()
                        isTextEditorFocused = true
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    Button {
                        isPreview.toggle()
                    } label: {
                        Image(systemName: isPreview ? "pencil" : "eye")
                    }
                    Button {
                        Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
            }
#endif
        }
        .onAppear {
            // Autofocus the editor on launch
            isTextEditorFocused = true
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            viewModel.handleScenePhaseChange(newPhase)
        }
    }
}

// MARK: - MarkdownUI Minimal Obsidian Theme
extension Theme {
    /// A minimal Obsidian-inspired MarkdownUI theme with transparent background,
    /// dynamic primary text color, and minimal padding.
    static let obsidianMinimal: Theme = Theme()
        // Headings: semibold and descending sizes
        .heading1 { config in
            config.label
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .heading2 { config in
            config.label
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .heading3 { config in
            config.label
                .font(.title3)
                .foregroundColor(.primary)
        }
        .heading4 { config in
            config.label
                .font(.headline)
                .foregroundColor(.primary)
        }
        .heading5 { config in
            config.label
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .heading6 { config in
            config.label
                .font(.footnote)
                .foregroundColor(.primary)
        }
        // Paragraphs and list items use body font
        .paragraph { config in
            config.label
                .font(.body)
                .foregroundColor(.primary)
        }
        .listItem { config in
            config.label
                .font(.body)
                .foregroundColor(.primary)
        }
}
