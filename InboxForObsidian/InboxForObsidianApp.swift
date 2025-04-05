import SwiftUI
import SwiftData

@main
struct InboxForObsidianApp: App {
    @State private var container: ModelContainer

    init() {
        do {
            // Identify your schema (the data models you want)
            let schema = Schema([InboxItem.self])
            
            // Specify a CloudKit container
            let config = ModelConfiguration("iCloud.obsidianInbox")

            // Create a ModelContainer using that config
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \\(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container) // Provide the container to your views
        }
    }
}
