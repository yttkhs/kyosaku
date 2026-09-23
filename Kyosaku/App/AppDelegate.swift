import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    let root = AppRoot(launch: .current)

    func applicationDidFinishLaunching(_ notification: Notification) {
        // The unit test bundle runs inside this app, and starting it would open windows mid-test.
        guard !root.launch.isHostingUnitTests else { return }
        root.start()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}
