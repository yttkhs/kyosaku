import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let root = AppRoot()

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
