import AppKit
import XCTest

final class DockIconUITests: XCTestCase {
    @MainActor
    func testShowsTheDockIconOnlyWhileAWindowIsOpen() {
        let app = XCUIApplication.launchKyosakuForTesting()
        XCTAssertTrue(app.staticTexts["menu.placeholder"].waitForExistence(timeout: 5))
        XCTAssertTrue(waitForActivationPolicy(.regular))

        app.windows.firstMatch.buttons[XCUIIdentifierCloseWindow].click()

        XCTAssertTrue(waitForActivationPolicy(.accessory))
    }

    @MainActor
    private func waitForActivationPolicy(_ expected: NSApplication.ActivationPolicy) -> Bool {
        let deadline = Date.now.addingTimeInterval(5)
        while Date.now < deadline {
            let running = NSRunningApplication.runningApplications(
                withBundleIdentifier: XCUIApplication.kyosakuBundleIdentifier
            )
            if running.first?.activationPolicy == expected {
                return true
            }
            RunLoop.current.run(until: Date.now.addingTimeInterval(0.1))
        }
        return false
    }
}
