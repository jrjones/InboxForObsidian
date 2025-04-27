# Inbox for Obsidian 
<img src="gfx/ifo-icon.png" width="128" align="right"> 

## Overview
A minimalist app for iOS (and iPadOS, MacOS, and VisionOS) for ultra-fast Markdown capture, tightly integrated with https://Obsidian.md 

Opens *instantly* to a text editor for quick note-taking or task capture, using local SwiftData storage (synced with iCloud) and a manual push to Obsidian to prevent sync conflicts.

# Core Features

 1.  Instant Launch: Starts in a focused text editor, no splash screen or delay. 
 2.  Quick Task Markers: Tap shortcut button to insert Markdown tasks. (e.g. `- [!]`) with ~20 status types using SF Symbols (designed to mirror the style and colors in the Obsidian Minimalist theme).
 3.  Local-First, iCloud-Synced: Persistence model uses SwiftData and iCloud sync. Each note is a record with content, creation date, and a synced flag.
 4.  Deferred Obsidian Sync: A “Push” button appends unsynced notes to the vault’s daily notes via obsidian://actions-uri, then marks them synced.
 5.  Smart Draft Retention: If you leave the app for under 30 seconds, your text remains. If longer, it saves that draft and clears for a fresh note.

## Screenshots
![Screenshot showing a menu of entry types](./gfx/ifo-screenshot1.png)

# Technical Notes

 - SwiftUI + SwiftData: iOS 17+/MacOS 15+ with CloudKit for private syncing.
 - Clipboard Awareness: When inserting a URL, short, or long text.
 - No Conflicts: Notes append to Obsidian using its Actions URI plugin.

# Next up prios

 - [x] Clean up Task Types, write some unit tests
 - [x] Data persistence
 - [x] Obsidian integration
 - [x] Background/foreground behavior (save and start new if foreground after > 30s, if < 30s stay on same item)
 - [x] Rotation and keyboard show/hide handling
 - [x] Native Vision OS support (with "ornaments" bar)
 - [x] Advanced paste behavior (handle URLs, short text, long text)
 - [x] SFSymbol icons (rendered and cached) for markdown shortcut bar
 - [x] Markdown preview with SFSymbol replacement
 - [ ] Voice ingest (WhisperKit)
 - [ ] "Server mode" menubar app on Mac makes syncs automatic, checks if Obsidian is running locally.
 - [ ] Better iOS and macOS citizen (UI/UX: SwiftUI improvements, theming, and advanced features.)
  
## Markdown Preview with MarkdownUI

Markdown preview powered by MarkdownUI

To enable full block-level GitHub-flavored Markdown (headings, lists, tables, code blocks, task lists, etc.)

We are modifying the in-memory representation so SFSymbols replace the markdown tasks in the preview so it looks similar to how it will be in Obsidian. We generate images for each SFSymbol at runtime, and cache the result for performance.

## Future enhancements
- CarPlay capture
- AppleWatch capture
- Archive instead of delete, archive management
- handling data types other than text and voice (photo, video, etc.)
- multiple vault andline
- AI features - low hanging fruit is selecting an appropriate icon when I don't have one. But there's a lot of ideas to explore. (This project is to some degree a platform for that exploration, but need some useful functionality first.)
