import AppKit

/// Whether an input method is still composing in the focused field, as in Japanese before conversion.
enum TextComposition {
    static var isActive: Bool {
        (NSApp.keyWindow?.firstResponder as? NSTextView)?.hasMarkedText() ?? false
    }
}
