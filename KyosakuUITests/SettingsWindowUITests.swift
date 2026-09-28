import XCTest

final class SettingsWindowUITests: XCTestCase {
    @MainActor
    func testOpensSettingsWithItsFiveTabs() {
        let app = XCUIApplication.launchKyosakuForTesting()
        XCTAssertTrue(app.buttons["tasks.newButton"].waitForExistence(timeout: 5))

        app.buttons["menu.settingsButton"].click()

        let toolbar = app.toolbars.firstMatch
        XCTAssertTrue(toolbar.waitForExistence(timeout: 5))
        for title in ["General", "Templates", "Privacy", "Permissions", "Stats"] {
            XCTAssertTrue(toolbar.buttons[title].exists, "The \(title) tab is missing")
        }
        toolbar.buttons["Templates"].click()
        XCTAssertTrue(app.descendants(matching: .any)["settings.pane.templates"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testCommandCommaOpensSettings() {
        let app = XCUIApplication.launchKyosakuForTesting()
        XCTAssertTrue(app.buttons["tasks.newButton"].waitForExistence(timeout: 5))

        app.typeKey(",", modifierFlags: .command)

        XCTAssertTrue(app.toolbars.firstMatch.waitForExistence(timeout: 5))
    }

    @MainActor
    func testReopeningSettingsKeepsOneWindow() {
        let app = XCUIApplication.launchKyosakuForTesting()
        XCTAssertTrue(app.buttons["menu.settingsButton"].waitForExistence(timeout: 5))
        app.buttons["menu.settingsButton"].click()
        XCTAssertTrue(app.toolbars.firstMatch.waitForExistence(timeout: 5))

        app.typeKey(",", modifierFlags: .command)

        XCTAssertEqual(app.toolbars.count, 1)
    }
}
