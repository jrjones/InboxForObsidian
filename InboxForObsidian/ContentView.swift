import SwiftUI
import SwiftData
import Foundation

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif


struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @FocusState private var isTextEditorFocused: Bool

    @StateObject private var viewModel: InboxViewModel

    // Inject ModelContext from the app for SwiftData operations.
    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: InboxViewModel(context: modelContext))
    }

    var body: some View {
        VStack {
            // Main text editor for drafting notes with smart paste handling.
            // Main text editor for drafting notes with smart paste handling.
            Group {
                #if canImport(UIKit)
                PasteHandlingTextEditor(text: $viewModel.draftText)
                #else
                PasteHandlingTextEditor(text: $viewModel.draftText,
                                         isFocused: $isTextEditorFocused)
                #endif
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .safeAreaInset(edge: .bottom) {
                // Bottom toolbar with New Note button and Markdown shortcuts.
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.startNewDraft()
                            isTextEditorFocused = true  // focus editor for new draft
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        Spacer()
                        // Markdown shortcut bar triggers push to Obsidian when its action is invoked.
                        MarkdownShortcutBar(draftText: $viewModel.draftText) {
                            Task {
                                await viewModel.pushNotesToObsidian(openURL: openURL)
                            }
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(.thinMaterial)
                }
                .padding()
        }
        .onAppear {
            // Focus the text editor when the view appears to allow immediate typing.
            isTextEditorFocused = true
        }
        .onChange(of: scenePhase) { newPhase in
            // Delegate scene phase changes (background/foreground) to the view model.
            viewModel.handleScenePhaseChange(newPhase)
        }
    }
}
