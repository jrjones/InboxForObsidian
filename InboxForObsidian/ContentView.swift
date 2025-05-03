import SwiftUI
import SwiftData
import Foundation
import MarkdownUI

// MARK: - Platform‑specific ContentView implementations
// VisionOS --------------------------------------------------------------
#if os(visionOS)
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL)   private var openURL
    @FocusState private var isTextEditorFocused: Bool

    @StateObject private var viewModel: InboxViewModel
    @State private var isPreview = false

    private enum ActionTab: Hashable { case newEntry, edit, preview, sync }
    @State private var selectedTab: ActionTab = .edit

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: InboxViewModel(context: modelContext))
    }

    // Shared editor / preview stack
    @ViewBuilder
    private var editorArea: some View {
        VStack {
            Group {
                if isPreview {
                    ScrollView {
                        TaskMarkdownPreview(markdown: viewModel.draftText)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                } else {
                    TextEditor(text: $viewModel.draftText)
                        .focused($isTextEditorFocused)
                }
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { print("🔥 TextEditor appeared") }
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // New Entry tab
            editorArea
                .tabItem { Label("New", systemImage: "plus.circle") }
                .tag(ActionTab.newEntry)

            // Edit tab
            editorArea
                .tabItem { Label("Edit", systemImage: "pencil") }
                .tag(ActionTab.edit)

            // Preview tab
            editorArea
                .tabItem { Label("Preview", systemImage: "eye") }
                .tag(ActionTab.preview)

            // Sync tab
            editorArea
                .tabItem { Label("Sync", systemImage: "arrow.triangle.2.circlepath") }
                .tag(ActionTab.sync)
        }
        .onChange(of: selectedTab) {
            // defer work to next run‑loop tick to avoid view‑update mutations
            DispatchQueue.main.async {
                switch selectedTab {
                case .newEntry:
                    viewModel.startNewDraft()
                    isTextEditorFocused = true

                case .edit:
                    isPreview = false
                    isTextEditorFocused = true

                case .preview:
                    isPreview = true
                    isTextEditorFocused = false

                case .sync:
                    Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            viewModel.handleScenePhaseChange(newPhase)
        }
        // Shortcut bar ornament
        MarkdownShortcutBar(
            draftText: $viewModel.draftText,
            showsSyncButton: false
        ) {
            Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
        }
    }
}
#endif // visionOS

// macOS --------------------------------------------------------------
#if os(macOS)
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL)   private var openURL
    @FocusState private var isTextEditorFocused: Bool

    @StateObject private var viewModel: InboxViewModel
    @State private var isPreview = false

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: InboxViewModel(context: modelContext))
    }

    @ViewBuilder
    private var editorArea: some View {
        VStack {
            Group {
                if isPreview {
                    ScrollView {
                        TaskMarkdownPreview(markdown: viewModel.draftText)
                            .padding(.top, 12)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                } else {
                    PasteHandlingTextEditor(text: $viewModel.draftText,
                                             isFocused: $isTextEditorFocused)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var body: some View {
        editorArea
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button {
                        viewModel.startNewDraft()
                        isTextEditorFocused = true
                    } label: { Image(systemName: "plus.circle") }
                    .help("New Entry")

                    Button {
                        isPreview.toggle()
                    } label: { Image(systemName: isPreview ? "pencil" : "eye") }
                    .help(isPreview ? "Edit" : "Preview")

                    Button {
                        Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                    } label: { Image(systemName: "arrow.triangle.2.circlepath") }
                    .help("Sync")
                }
            }
            .toolbarRole(.automatic)
            .onAppear { isTextEditorFocused = true }
            // Use two-parameter onChange to satisfy macOS 14+ deprecation
            .onChange(of: scenePhase) { _, newPhase in
                viewModel.handleScenePhaseChange(newPhase)
            }
            // Markdown shortcut bar (bottom inset, macOS)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    MarkdownShortcutBar(draftText: $viewModel.draftText,
                                        showsSyncButton: false) {
                        Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(.thinMaterial)
            }
    }
}
#endif // macOS

// iOS / iPadOS --------------------------------------------------------
#if os(iOS)
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL)   private var openURL
    @FocusState private var isTextEditorFocused: Bool

    @StateObject private var viewModel: InboxViewModel
    @State private var isPreview = false

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: InboxViewModel(context: modelContext))
    }

    @ViewBuilder
    private var editorArea: some View {
        VStack {
            Group {
                if isPreview {
                    ScrollView {
                        TaskMarkdownPreview(markdown: viewModel.draftText)
                            .padding(.top, 12)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                } else {
                    PasteHandlingTextEditor(text: $viewModel.draftText)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var body: some View {
        editorArea
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        viewModel.startNewDraft()
                        isTextEditorFocused = true
                    } label: { Image(systemName: "plus.circle") }
                    .help("New Entry")
                }

                ToolbarItem(placement: .automatic) {
                    Button { isPreview.toggle() } label: {
                        Image(systemName: isPreview ? "pencil" : "eye")
                    }
                    .help(isPreview ? "Edit" : "Preview")
                }

                ToolbarItem(placement: .automatic) {
                    Button {
                        Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                    } label: { Image(systemName: "arrow.triangle.2.circlepath") }
                    .help("Sync")
                }
            }
            .toolbarRole(.automatic)
            .onAppear { isTextEditorFocused = true }
            // Use two-parameter onChange to satisfy iOS 18+ deprecation
            .onChange(of: scenePhase) { _, newPhase in
                viewModel.handleScenePhaseChange(newPhase)
            }
            // Shortcut bar inset
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    MarkdownShortcutBar(draftText: $viewModel.draftText,
                                        showsSyncButton: false) {
                        Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(.thinMaterial)
            }
    }
}
#endif // iOS

// MARK: - VisionOS expanding‑label button style
/// A button style that shows only the SF Symbol by default and
/// widens to reveal the text when the user hovers / gazes at it.
/// Collapsed width is fixed at 44 pt so all buttons align.
struct ExpandingIconOnlyButtonStyle: ButtonStyle {
    private struct HoverView: View {
        @State private var isHovered = false
        let configuration: Configuration

        var body: some View {
            Group {
                if isHovered {
                    configuration.label
                        .labelStyle(.titleAndIcon)
                } else {
                    configuration.label
                        .labelStyle(.iconOnly)
                }
            }
            .frame(minWidth: 44)                         // equal collapsed width
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .onHover { hover in
                isHovered = hover
            }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        HoverView(configuration: configuration)
    }
}
