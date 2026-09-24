import XCTest

final class TaskListUITests: XCTestCase {
    @MainActor
    func testStartsWithOnlyTheNewTaskButton() {
        let app = XCUIApplication.launchKyosakuForTesting()

        XCTAssertTrue(app.buttons["tasks.newButton"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.taskNamesInOrder(), [])
        XCTAssertFalse(app.buttons["tasks.completedToggle"].exists)
    }

    @MainActor
    func testPutsTheNewestTaskFirst() {
        let app = XCUIApplication.launchKyosakuForTesting()

        app.addTask(named: "Read the RFC")
        app.addTask(named: "Fix the login bug")

        XCTAssertEqual(app.taskNamesInOrder(), ["Fix the login bug", "Read the RFC"])
    }

    @MainActor
    func testAddsATaskOnlyOnceItHasAName() {
        let app = XCUIApplication.launchKyosakuForTesting()
        XCTAssertTrue(app.buttons["tasks.newButton"].waitForExistence(timeout: 5))
        app.buttons["tasks.newButton"].click()
        let name = app.textFields["taskForm.nameField"]
        let submit = app.buttons["taskForm.submitButton"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        XCTAssertFalse(submit.isEnabled)

        name.click()
        name.typeText("   ")
        XCTAssertFalse(submit.isEnabled)
        name.typeText("Plan")

        XCTAssertTrue(submit.isEnabled)
    }

    @MainActor
    func testRenamesATaskFromItsName() {
        let app = XCUIApplication.launchKyosakuForTesting()
        app.addTask(named: "Draft")

        app.control("task.nameButton", ofTask: "Draft").click()
        let name = app.textFields["taskForm.nameField"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.click()
        name.typeKey("a", modifierFlags: .command)
        name.typeText("Final")
        app.buttons["taskForm.submitButton"].click()

        XCTAssertTrue(app.taskRow(named: "Final").waitForExistence(timeout: 5))
        XCTAssertFalse(app.taskRow(named: "Draft").exists)
    }
}
