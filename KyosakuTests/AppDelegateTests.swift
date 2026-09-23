import AppKit
import Testing

struct AppDelegateTests {
    @Test func skipsTheLaunchSequenceWhileHostingTheseTests() {
        // Where the welcome has not been seen, such as on CI, start() would open it and show the Dock icon.
        #expect(NSApp.activationPolicy() == .accessory)
    }
}
