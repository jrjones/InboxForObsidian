import SwiftUI
import SwiftData

@main
struct InboxForObsidianApp: App {
    @Environment(\.openWindow) private var openWindow
    @State private var container: ModelContainer
    init() {
        do {
            let schema = Schema([InboxItem.self])
            // Use SwiftData’s default persistent configuration.
            container = try ModelContainer(for: schema)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            #if os(visionOS)
            ContentView(modelContext: container.mainContext)
                .modelContainer(container) // Provide the container to your views
            #else
            NavigationStack {
                ContentView(modelContext: container.mainContext)
            }
            .modelContainer(container)
            #endif
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Inbox for Obsidian") {
                    openWindow(id: "about")
                }
            }
        }

        #if os(macOS)
        Window("About Inbox for Obsidian", id: "about") {
            AboutView()
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
        #endif
    }
}
