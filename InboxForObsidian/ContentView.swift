import SwiftUI
import SwiftData
import Foundation
import MarkdownUI

#if false    // legacy mixed‑platform implementation (disabled)
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL
    @FocusState private var isTextEditorFocused: Bool

    @StateObject private var viewModel: InboxViewModel
    @State private var isPreview: Bool = false

    #if os(visionOS)
    private enum ActionTab: Hashable { case main, newEntry, togglePreview, sync }
    @State private var selectedTab: ActionTab = .main
    #endif

    /// Inject the ModelContext from the app for SwiftData operations.
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
    #if canImport(UIKit)
                    PasteHandlingTextEditor(text: $viewModel.draftText)
    #else
                    PasteHandlingTextEditor(text: $viewModel.draftText,
                                             isFocused: $isTextEditorFocused)
    #endif
                }
            }
        #if os(visionOS)
            .padding(.horizontal, 48)
            .padding(.vertical, 24)
        #endif
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var body: some View {
    #if os(visionOS)
        TabView(selection: $selectedTab) {
            // New Entry tab
            editorArea
                .tabItem { Label("New", systemImage: "plus.circle") }
                .tag(ActionTab.newEntry)

            // Toggle Preview / Edit tab (label & icon depend on state)
            editorArea
                .tabItem { Label(isPreview ? "Edit" : "Preview",
                                 systemImage: isPreview ? "pencil" : "eye") }
                .tag(ActionTab.togglePreview)

            // Sync tab
            editorArea
                .tabItem { Label("Sync", systemImage: "arrow.triangle.2.circlepath") }
                .tag(ActionTab.sync)
        }
        .onChange(of: selectedTab) { tab in
            switch tab {
            case .newEntry:
                viewModel.startNewDraft()
                isTextEditorFocused = true
            case .togglePreview:
                isPreview.toggle()
            case .sync:
                Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
            default:
                break
            }
            selectedTab = .main        // collapse labels after the action
        }
        .onAppear {
            isTextEditorFocused = true
        }
        .onChange(of: scenePhase) { newPhase in
            viewModel.handleScenePhaseChange(newPhase)
        }
     #elseif os(macOS)
          // macOS toolbar — use identifiable content to avoid overload conflict
          editorArea
              .toolbar(visibility: .automatic) {
                  ToolbarItemGroup(placement: .automatic) {
                      // New Entry
                      Button {
                          viewModel.startNewDraft()
                          isTextEditorFocused = true
                      } label: {
                          Image(systemName: "plus.circle")
                      }
                      .help("New Entry")

                      // Toggle Preview / Edit
                      Button {
                          isPreview.toggle()
                      } label: {
                          Image(systemName: isPreview ? "pencil" : "eye")
                      }
                      .help(isPreview ? "Edit" : "Preview")

                      // Sync
                      Button {
                          Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                      } label: {
                          Image(systemName: "arrow.triangle.2.circlepath")
                      }
                      .help("Sync")
                  }
              }
              .toolbarRole(.automatic)
              .onAppear { isTextEditorFocused = true }
              .onChange(of: scenePhase) { newPhase in
                  viewModel.handleScenePhaseChange(newPhase)
              }

      #else   // iOS (and iPadOS, tvOS)
          editorArea
              .toolbar {
                  // New Entry
                  ToolbarItem(placement: .automatic) {
                      Button {
                          viewModel.startNewDraft()
                          isTextEditorFocused = true
                      } label: {
                          Image(systemName: "plus.circle")
                      }
                      .help("New Entry")
                  }

                  // Toggle Preview / Edit
                  ToolbarItem(placement: .automatic) {
                      Button {
                          isPreview.toggle()
                      } label: {
                          Image(systemName: isPreview ? "pencil" : "eye")
                      }
                      .help(isPreview ? "Edit" : "Preview")
                  }

                  // Sync
                  ToolbarItem(placement: .automatic) {
                      Button {
                          Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
                      } label: {
                          Image(systemName: "arrow.triangle.2.circlepath")
                      }
                      .help("Sync")
                  }
              }
              .toolbarRole(.automatic)
              .onAppear { isTextEditorFocused = true }
              .onChange(of: scenePhase) { newPhase in
                  viewModel.handleScenePhaseChange(newPhase)
              }
    #endif
        // Shortcut bar inset (non-visionOS)
    #if !os(visionOS)
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
    #endif
        // Shortcut bar ornament (visionOS)
    #if os(visionOS)
        MarkdownShortcutBar(
            draftText: $viewModel.draftText,
            showsSyncButton: false
        ) {
            Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
        }
    #endif
    }
}
#endif       // end legacy implementation

// MARK: - Platform‑specific ContentView implementations
// VisionOS --------------------------------------------------------------
#if os(visionOS)
struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL)   private var openURL
    @FocusState private var isTextEditorFocused: Bool

    @StateObject private var viewModel: InboxViewModel
    @State private var isPreview = false

    private enum ActionTab: Hashable { case main, newEntry, togglePreview, sync }
    @State private var selectedTab: ActionTab = .main

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
#if canImport(UIKit)
                    PasteHandlingTextEditor(text: $viewModel.draftText)
#else
                    PasteHandlingTextEditor(text: $viewModel.draftText,
                                             isFocused: $isTextEditorFocused)
#endif
                }
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // New Entry tab
            editorArea
                .tabItem { Label("New", systemImage: "plus.circle") }
                .tag(ActionTab.newEntry)

            // Toggle Preview / Edit tab
            editorArea
                .tabItem { Label(isPreview ? "Edit" : "Preview",
                                 systemImage: isPreview ? "pencil" : "eye") }
                .tag(ActionTab.togglePreview)

            // Sync tab
            editorArea
                .tabItem { Label("Sync", systemImage: "arrow.triangle.2.circlepath") }
                .tag(ActionTab.sync)
        }
        .onChange(of: selectedTab) { tab in
            switch tab {
            case .newEntry:
                viewModel.startNewDraft()
                isTextEditorFocused = true
            case .togglePreview:
                isPreview.toggle()
            case .sync:
                Task { await viewModel.pushNotesToObsidian(openURL: openURL) }
            default: break
            }
            selectedTab = .main        // collapse labels after the action
        }
        .onAppear { isTextEditorFocused = true }
        .onChange(of: scenePhase) { newPhase in
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
            .onChange(of: scenePhase) { newPhase in
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
            .onChange(of: scenePhase) { newPhase in
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

/*
#if os(visionOS)
/// Toolbar button that shows only its SF Symbol by default
/// and reveals the text label when hovered / gazed at.
/// Width is fixed so all buttons stay aligned.
struct ToolbarIconButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    var help: String? = nil

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: 44, height: 44)                    // equal width/height
                .contentShape(Rectangle())                      // full‑width hit area
                .overlay(alignment: .leading) {
                    if isHovered {
                        Text(title)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.thinMaterial, in: Capsule())
                            .offset(x: 50)                       // reveal to the right
                            .transition(.move(edge: .trailing)
                                        .combined(with: .opacity))
                    }
                }
        }
        .buttonStyle(.plain)                                    // keep system tint
        .onHover { isHovered = $0 }                             // track gaze/hover
        .help(help ?? title)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
    }
}
#endif
*/

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
