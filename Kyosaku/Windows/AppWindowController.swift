import AppKit
import SwiftUI

/// Owns one titled window: built on first show, and released on close so its views deallocate.
final class AppWindowController: NSObject, NSWindowDelegate {
    private let title: String
    private let contentSize: CGSize
    private let toolbarStyle: NSWindow.ToolbarStyle
    private let activationPolicy: ActivationPolicy
    private var window: NSWindow?

    init(
        title: String,
        contentSize: CGSize,
        toolbarStyle: NSWindow.ToolbarStyle = .automatic,
        activationPolicy: ActivationPolicy
    ) {
        self.title = title
        self.contentSize = contentSize
        self.toolbarStyle = toolbarStyle
        self.activationPolicy = activationPolicy
        super.init()
    }

    var isShowing: Bool { window != nil }

    /// Shows a SwiftUI view. The view is only built when no window is open yet.
    func show<Content: View>(rootView: @autoclosure () -> Content) {
        show(viewController: makeHostingController(rootView: rootView()))
    }

    /// Shows a view controller, or brings the window that is already open to the front.
    func show(viewController: @autoclosure () -> NSViewController) {
        if let window {
            bringToFront(window)
            return
        }
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: contentSize),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = title
        window.toolbarStyle = toolbarStyle
        window.isReleasedWhenClosed = false
        // AppKit would otherwise reopen the window at the next launch, before the app has started.
        window.isRestorable = false
        window.delegate = self
        window.contentViewController = viewController()
        window.setContentSize(contentSize)
        window.center()
        self.window = window
        activationPolicy.windowDidOpen(window)
        bringToFront(window)
    }

    func close() {
        window?.close()
    }

    func windowWillClose(_ notification: Notification) {
        guard let window else { return }
        self.window = nil
        activationPolicy.windowDidClose(window)
    }

    private func makeHostingController<Content: View>(rootView: Content) -> NSViewController {
        let controller = NSHostingController(rootView: rootView)
        // Keeps the window's size in charge; SwiftUI would otherwise resize the window to fit its content.
        controller.sizingOptions = []
        return controller
    }

    private func bringToFront(_ window: NSWindow) {
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }
}
