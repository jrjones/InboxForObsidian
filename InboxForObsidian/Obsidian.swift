import Foundation

func makeDailyFilePath() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dateString = formatter.string(from: Date())
    return "Daily/\(dateString).md"
}

func obsidianAppendURL(content: String) -> URL? {
    var components = URLComponents()
    components.scheme = "obsidian"
    components.host = "advanced-uri"
    components.queryItems = [
        URLQueryItem(name: "vault", value: "Obsidian Sandbox"), // or from Info.plist
        URLQueryItem(name: "filepath", value: makeDailyFilePath()),
        URLQueryItem(name: "append", value: "\n- " + content)
    ]
    return components.url
}
