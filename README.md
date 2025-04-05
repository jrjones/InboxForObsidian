# Inbox for Obsidian -- MVP Specification

## Overview

**Inbox for Obsidian** is an iOS application for ultra-fast capture of notes and tasks in Markdown, tightly integrated with the Obsidian.md knowledge management system. It enables users to jot down notes or to-do items instantly and categorize them with task markers, then later sync those entries into Obsidian's Daily Notes. The design emphasizes minimal UI and immediate responsiveness, so users can open the app and start typing with zero delay. Integration with Obsidian occurs via a safe, deferred push using Obsidian's Actions URI plugin (by Carlo Zottmann) to append captured notes to the appropriate Daily Note in the vault, ensuring no conflicts with Obsidian's own sync.

## Core Goals

- **Instant Capture:** Launch directly into a focused Markdown text editor, ready for input without loading or sync delays.

- **Task-Type Notation:** Quickly mark notes as specific task types using Markdown syntax (e.g. [!] for important, [?] for question) with SFSymbol icon shortcuts for easy insertion.

- **Local-First Storage:** Store all entries locally using SwiftData (with CloudKit for iCloud sync) for reliability and offline use. Sync data silently across the user's iOS devices via iCloud.

- **Deferred Safe Sync:** Rather than live-syncing to Obsidian, collect notes in an "inbox" queue. Sync to Obsidian is manual and uses Obsidian's URI interface to safely append content (no direct file writing), preventing conflicts and ensuring data integrity.

## Key Features and UX Flow

### 1. Instant Launch & Quick Input

- **Fast Startup:** The app is optimized to load to the editor immediately. On launch, the main view is a text editor with no splash screens or menus. The keyboard is auto-focused so the user can start typing instantly. Any background sync (CloudKit, etc.) is non-blocking to avoid delay.

- **Single-purpose UI:** The entire home screen is a Markdown text field (using TextEditor in SwiftUI) occupying most of the screen, plus a small toolbar. There is no initial navigation--just "open and type."
- **Auto-Focus:** The text field gains focus on launch, bringing up the keyboard by default. This allows capturing an idea or task in as little as one tap (to launch the app) and immediate typing.
- **Technical:******

    - Implement with SwiftUI's @FocusState or .focused(...) modifier to programmatically focus the TextEditor on appear.

    - Ensure App launch logic does not perform heavy tasks (like CloudKit container setup) synchronously; those can initialize in the background after the UI is ready.

  

### 2. Persistent Draft State (Temporal Draft Retention)

- **Use Case:** If a user switches away from the app briefly (to copy information, etc.) and returns, they should find their in-progress note as they left it. However, if the app has been in the background for a longer period (user likely started a new context), the app should start fresh to encourage quick, discrete notes.
- **Behavior:******

    - If the user returns to the app within **30 seconds** of leaving, the previous draft remains on screen for continued editing. The state (text content and cursor position) is preserved.

    - If more than **30 seconds** have passed since the user left, any in-progress draft is considered stale: the app clears the editor and presents a blank note input. The old draft (if it had any content) is saved to the queue (see **Note Queueing**) when the app went to background, so no data is lost.
- **Implementation Logic:******

    - On sceneWillResignActive (app going to background), record a timestamp and temporarily hold the current text content. If content is non-empty, prepare to save it after a timeout.

    - If the app becomes active again within 30 seconds, do not finalize the save; instead restore the held draft content (which may still be in memory).

    - If the app was backgrounded for longer than 30 seconds (or was terminated), finalize the draft: save the content to SwiftData as a new note entry, then clear the editor for a fresh start on next launch.
  

### 3. Always-On Markdown Toolbar with Task Shortcuts

- **Markdown Shortcut Bar:** A toolbar sits **above the keyboard** at all times, providing one-tap insertion for common Markdown syntax and task markers.
- **Formatting Buttons:** Quick insert buttons for Markdown elements (bold **...**, italic *...*, checklist - [ ], headings #, etc.).
- **Task Type Menu:** A dedicated **Task Type** button opens a compact menu of ~20 task markers with SF Symbol icons. Examples include [!], [?], [b], [i], etc.
- **Grouped Categories:** To avoid a giant list, group the 20 types (e.g. "Priority," "Queries," "References," "Misc").
- **Insertion Behavior:** Selecting a task type inserts - [!] (or similar) at the current line.
- **Technical:******

    - Use SwiftUI's Menu or a custom popover for the grouped picker.

    - For text insertion, manipulate the bound string or use a UIKit text view bridge to insert at cursor position.

    - Keep the toolbar compact above the keyboard via .toolbar with .keyboard placement.

  
### 4. Clipboard-Aware "Paste" for Link Tasks

- **Context:** When inserting a "bookmark" task type ([b]), the app can detect the placeholder - [b] []() and handle URLs or text from the clipboard intelligently.
- **Smart Paste Behavior:******

    - If clipboard is a **URL**: Insert it in parentheses ()(url) and place cursor between [].

    - If clipboard is **text <100 chars**: Insert it between [], leave () empty, and move cursor to a new line below.

    - If **≥100 chars**: Append as an indented new line under the item.
- **Implementation Details:******

    - UIPasteboard to read content.

    - Enable a "Paste" toolbar button only if the current line matches - [b] []().

    - Indent long pasted text so it visually associates with the list item in Markdown.

  

### 5. Note Queueing and Local Persistence (SwiftData + CloudKit)
- **Local Inbox Database:** Each captured note is saved as an "inbox entry" in SwiftData, iCloud-synced for durability and multi-device support.
- **Data Model** (@Model):

    - id (UUID/auto-generated)

    - content (String)

    - createdAt (Date)

    - targetDate (Date) -- typically same day as createdAt

    - synced (Bool) -- true if pushed to Obsidian

- **iCloud Sync:** SwiftData + CloudKit means all notes sync privately across the user's devices.

- **Queue Management:******

    - No complex list UI in MVP; everything is background.

    - Possibly show a badge with unsynced note count on the "Push" button.

  
### 6. Manual Push to Obsidian (Deferred Sync)

- **User-Initiated Sync:** A "Push to Obsidian" button triggers manual appending of queued notes to the daily notes in Obsidian.
- **Obsidian Actions URI Plugin:******

    - Use obsidian://actions-uri/note/append (or daily-note/append) with parameters to target the daily note.

    - Multiple notes can be appended in one or multiple calls.
- **Flow:******

    1. User taps "Push."

    2. The app groups unsynced notes by targetDate.

    3. Construct the appropriate obsidian://actions-uri/note/append?... URL, including vault=, file=, content=, and possibly create-if-not-found=true & silent=true.

    4. Open the URL (switches to Obsidian), plugin appends text.

    5. On success callback (x-callback-url), mark notes as synced or remove them from the queue.

    6. If error, remain unsynced and notify the user.

- **Data Format in Obsidian:** The appended text is exactly what was typed in the app.

  

## Technical Implementation Details

- **Frameworks**: SwiftUI + SwiftData, iOS 17+ target.

- **SwiftData Container**: CloudKit-backed for private iCloud sync.

- **Performance**: Avoid blocking main thread with heavy tasks or CloudKit initialization.

- **Clipboard Monitoring**: Only read clipboard on explicit user action to comply with iOS privacy rules.

- **Security & Privacy**: Data remains on-device or iCloud private database. The only external calls are via Obsidian's local URL scheme.

## Conclusion

Inbox for Obsidian MVP delivers a focused, fast note-taking experience for Obsidian enthusiasts. By combining a frictionless UI (instant-on editor, handy markdown toolbar) with a robust technical backbone (SwiftUI/SwiftData + CloudKit, plus Obsidian's Actions URI plugin), it achieves the goal of _quick capture now, organize later_. All core flows--capturing a note, marking it up, queuing it, and eventually pushing it to the vault--are detailed above, providing a clear blueprint for development.
