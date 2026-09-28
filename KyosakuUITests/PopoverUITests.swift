import XCTest

final class PopoverUITests: XCTestCase {
    @MainActor
    func testNewTaskLetsYouTypeTheNameRightAway() {
        let app = XCUIApplication.openKyosakuPopoverForTesting()
        app.buttons["tasks.newButton"].click()
        let name = app.textFields["taskForm.nameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))

        app.typeText("Typed")

        XCTAssertEqual(name.value as? String, "Typed")
    }

    @MainActor
    func testEscapeInTheFormGoesBackToTheList() {
        let app = XCUIApplication.openKyosakuPopoverForTesting()
        app.buttons["tasks.newButton"].click()
        XCTAssertTrue(app.textFields["taskForm.nameField"].waitForExistence(timeout: 5))

        app.typeKey(XCUIKeyboardKey.escape.rawValue, modifierFlags: [])

        XCTAssertTrue(app.buttons["tasks.newButton"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["tasks.newButton"].isHittable)
    }
}
