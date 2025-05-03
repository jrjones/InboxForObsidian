//
//  PasteHandlingTextEditor.swift
//  InboxForObsidian
//
//  Adds smart paste behavior: URLs become markdown links with cursor in link text,
//  short text becomes markdown tasks, long text pastes unchanged.

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
/// A UIViewRepresentable text editor that intercepts paste actions for smart behavior.
/// A UIViewRepresentable text editor that intercepts paste actions for smart behavior.
struct PasteHandlingTextEditor: UIViewRepresentable {
    @Binding var text: String
    /// Optional focus binding for controlling first responder state.
    var isFocused: FocusState<Bool>.Binding? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = PasteTextView()
        textView.delegate = context.coordinator
        textView.smartPasteDelegate = context.coordinator
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.autocorrectionType = .yes
        textView.autocapitalizationType = .sentences
        // Remove default text container insets for full-bleed content
        // Add top padding inside the editor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        // Sync text
        if uiView.text != text {
            uiView.text = text
        }
        // Sync focus if binding provided
        if let isFocusedBinding = isFocused {
            if isFocusedBinding.wrappedValue && !uiView.isFirstResponder {
                uiView.becomeFirstResponder()
            } else if !isFocusedBinding.wrappedValue && uiView.isFirstResponder {
                uiView.resignFirstResponder()
            }
        }
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textViewDidChange(_ textView: UITextView) {
            let latest = textView.text ?? ""
            // Defer the SwiftUI state update to the next run‑loop tick.
            DispatchQueue.main.async {
                self.text = latest
            }
        }


        /// Handle paste to apply smart formatting.
        func handlePaste(in textView: PasteTextView) {
            guard let pasted = UIPasteboard.general.string else {
                return
            }
            let trimmed = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
            let (insertString, cursorOffset): (String, Int)
            if let url = URL(string: trimmed), let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) {
                let link = "[](\(trimmed))"
                insertString = link
                cursorOffset = 1
            } else if trimmed.contains("\n") || trimmed.count > 100 {
                insertString = pasted
                cursorOffset = pasted.count
            } else {
                let ns = textView.text as NSString
                let selRange = textView.selectedRange
                let location = selRange.location
                let lineStart: Int = {
                    if location > 0 {
                        let r = ns.range(of: "\n", options: .backwards, range: NSRange(location: 0, length: location))
                        return (r.location != NSNotFound) ? r.location + r.length : 0
                    }
                    return 0
                }()
                let prefixRange = NSRange(location: lineStart, length: location - lineStart)
                let linePrefix = ns.substring(with: prefixRange).trimmingCharacters(in: .whitespaces)
                let taskPrefix = linePrefix.hasPrefix("- [ ]") ? "" : "- [ ] "
                insertString = taskPrefix + pasted
                cursorOffset = insertString.count
            }
            let current = textView.text as NSString
            let sel = textView.selectedRange
            let updated = current.replacingCharacters(in: sel, with: insertString)
            textView.text = updated
            DispatchQueue.main.async {
                self.text = updated
            }
            let newPos = sel.location + cursorOffset
            if let start = textView.position(from: textView.beginningOfDocument, offset: newPos) {
                textView.selectedTextRange = textView.textRange(from: start, to: start)
            }
        }

    }

    class PasteTextView: UITextView {
        /// Delegate for smart paste handling (avoid conflicting with UIKit's pasteDelegate)
        weak var smartPasteDelegate: Coordinator?

        override func paste(_ sender: Any?) {
            if let delegate = smartPasteDelegate {
                delegate.handlePaste(in: self)
            } else {
                super.paste(sender)
            }
        }
    }
}
#elseif canImport(AppKit)
/// NSScrollView subclass that forwards clicks to its document NSTextView for focus.
fileprivate class PasteScrollView: NSScrollView {
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        // Forward focus to the text view
        if let tv = documentView as? NSTextView {
            window?.makeFirstResponder(tv)
        }
    }
}
/// An NSViewRepresentable text editor that intercepts paste actions for smart behavior.
struct PasteHandlingTextEditor: NSViewRepresentable {
    @Binding var text: String
    /// Optional focus binding for controlling first responder state.
    var isFocused: FocusState<Bool>.Binding? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        // Use a custom scroll view to forward clicks to the text view
        let scrollView = PasteScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = [.width, .height]
        let contentSize = scrollView.contentSize
        let tv = PasteTextView(frame: NSRect(origin: .zero, size: contentSize))
        tv.delegate = context.coordinator
        tv.pasteDelegate = context.coordinator
        tv.isRichText = false
        tv.importsGraphics = false
        tv.allowsUndo = true
        // Ensure editable and selectable so it can become first responder
        tv.isEditable = true
        tv.isSelectable = true
        tv.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        // Add top padding inside the editor
        tv.textContainerInset = NSSize(width: 0, height: 12)
        // Configure resizing so the text view fills the scrollView
        tv.minSize = NSSize(width: 0, height: contentSize.height)
        tv.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        tv.isVerticallyResizable = true
        tv.isHorizontallyResizable = false
        tv.autoresizingMask = [.width]
        tv.textContainer?.containerSize = NSSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        tv.textContainer?.widthTracksTextView = true
        scrollView.documentView = tv
        context.coordinator.textView = tv
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let tv = context.coordinator.textView else { return }
        if tv.string != text {
            tv.string = text
        }
        // Sync focus: defer until the view is attached to a window
        if let isFocusedBinding = isFocused, isFocusedBinding.wrappedValue {
            DispatchQueue.main.async {
                tv.window?.makeFirstResponder(tv)
            }
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        weak var textView: PasteTextView?

        init(text: Binding<String>) {
            _text = text
        }

        func textDidChange(_ notification: Notification) {
            if let tv = textView {
                text = tv.string
            }
        }

        func handlePaste(in textView: PasteTextView) {
            let pb = NSPasteboard.general
            guard let pasted = pb.string(forType: .string) else {
                textView.paste(nil)
                return
            }
            let trimmed = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
            var insertString = pasted
            var cursorOffset: Int = pasted.count
            if let url = URL(string: trimmed), let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme) {
                insertString = "[](\(trimmed))"
                cursorOffset = 1
            } else if trimmed.contains("\n") || trimmed.count > 100 {
                insertString = pasted
                cursorOffset = pasted.count
            } else {
                let ns = textView.string as NSString
                // selectedRanges.first is already NSValue?
                let selRange = textView.selectedRanges.first
                let sel = selRange?.rangeValue ?? NSRange(location: 0, length: 0)
                let cursorLoc = sel.location
                let lineStart: Int
                if cursorLoc > 0 {
                    let r = ns.range(of: "\n", options: .backwards, range: NSRange(location: 0, length: cursorLoc))
                    lineStart = (r.location != NSNotFound) ? r.location + r.length : 0
                } else {
                    lineStart = 0
                }
                let prefixRange = NSRange(location: lineStart, length: cursorLoc - lineStart)
                let linePrefix = ns.substring(with: prefixRange).trimmingCharacters(in: .whitespaces)
                let taskPrefix = linePrefix.hasPrefix("- [ ]") ? "" : "- [ ] "
                insertString = taskPrefix + pasted
                cursorOffset = insertString.count
            }
            let full = textView.string as NSString
            // selectedRanges.first is already NSValue?
            let selValue = textView.selectedRanges.first
            let sel = selValue?.rangeValue ?? NSRange(location: 0, length: 0)
            let updated = full.replacingCharacters(in: sel, with: insertString)
            textView.string = updated
            text = updated
            let newLoc = sel.location + cursorOffset
            textView.setSelectedRange(NSRange(location: newLoc, length: 0))
        }
    }

    /// NSTextView subclass to intercept paste.
    class PasteTextView: NSTextView {
        weak var pasteDelegate: Coordinator?

        override func paste(_ sender: Any?) {
            pasteDelegate?.handlePaste(in: self)
        }
    }
}
#endif
