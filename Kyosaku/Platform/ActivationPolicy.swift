import AppKit

/// Shows the Dock icon only while one of Kyosaku's windows is open, so ⌘Tab can reach it.
final class ActivationPolicy {
    private let apply: (NSApplication.ActivationPolicy) -> Void
    private var openWindows: Set<ObjectIdentifier> = []

    init(apply: @escaping (NSApplication.ActivationPolicy) -> Void = { _ = NSApp.setActivationPolicy($0) }) {
        self.apply = apply
    }

    func windowDidOpen(_ window: NSWindow) {
        let wasEmpty = openWindows.isEmpty
        // Keyed by identity rather than counted, so a repeated open or close cannot strand the Dock icon.
        guard openWindows.insert(ObjectIdentifier(window)).inserted, wasEmpty else { return }
        apply(.regular)
    }

    func windowDidClose(_ window: NSWindow) {
        guard openWindows.remove(ObjectIdentifier(window)) != nil, openWindows.isEmpty else { return }
        apply(.accessory)
    }
}
