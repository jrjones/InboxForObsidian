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
                    ScrollView {
                        Markdown(viewModel.draftText)
                            .markdownTheme(.gitHub)
                            .textSelection(.enabled)
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
        .onChange(of: scenePhase) { newPhase in
            viewModel.handleScenePhaseChange(newPhase)
        }
    }
}
