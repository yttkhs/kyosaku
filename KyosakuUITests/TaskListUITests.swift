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

    @MainActor
    func testWorkingOnATaskMovesItToTheTop() {
        let app = XCUIApplication.launchKyosakuForTesting()
        for name in ["First", "Second", "Third"] {
            app.addTask(named: name)
        }

        app.control("task.activeToggle", ofTask: "First").click()
        XCTAssertEqual(app.taskNamesInOrder(), ["First", "Third", "Second"])

        app.control("task.activeToggle", ofTask: "Second").click()
        XCTAssertEqual(app.taskNamesInOrder(), ["Second", "Third", "First"])
    }

    @MainActor
    func testStoppingWorkPutsTheTaskBack() {
        let app = XCUIApplication.launchKyosakuForTesting()
        app.addTask(named: "Older")
        app.addTask(named: "Newer")
        app.control("task.activeToggle", ofTask: "Older").click()
        XCTAssertEqual(app.taskNamesInOrder(), ["Older", "Newer"])

        app.control("task.activeToggle", ofTask: "Older").click()

        XCTAssertEqual(app.taskNamesInOrder(), ["Newer", "Older"])
    }

    @MainActor
    func testRestoresACompletedTask() {
        let app = XCUIApplication.launchKyosakuForTesting()
        app.addTask(named: "Ship it")

        app.control("task.completeButton", ofTask: "Ship it").click()
        XCTAssertEqual(app.taskNamesInOrder(), [])
        app.buttons["tasks.completedToggle"].click()
        app.control("task.restoreButton", ofTask: "Ship it").click()

        XCTAssertTrue(app.control("task.activeToggle", ofTask: "Ship it").waitForExistence(timeout: 5))
    }

    @MainActor
    func testDeletesATaskOnlyAfterConfirming() {
        let app = XCUIApplication.launchKyosakuForTesting()
        app.addTask(named: "Old idea")

        app.control("task.deleteButton", ofTask: "Old idea").click()
        app.control("task.cancelDeleteButton", ofTask: "Old idea").click()
        XCTAssertTrue(app.taskRow(named: "Old idea").exists)

        app.control("task.deleteButton", ofTask: "Old idea").click()
        app.control("task.confirmDeleteButton", ofTask: "Old idea").click()

        XCTAssertTrue(app.taskRow(named: "Old idea").waitForNonExistence(timeout: 5))
    }

    @MainActor
    func testNamesTheControlsThatShowOnlyAnIcon() {
        let app = XCUIApplication.launchKyosakuForTesting()
        app.addTask(named: "Label check")

        XCTAssertEqual(app.control("task.activeToggle", ofTask: "Label check").label, "In Progress")
        XCTAssertEqual(app.control("task.completeButton", ofTask: "Label check").label, "Complete")
        XCTAssertEqual(app.control("task.deleteButton", ofTask: "Label check").label, "Delete")
        app.control("task.completeButton", ofTask: "Label check").click()
        app.buttons["tasks.completedToggle"].click()

        XCTAssertEqual(app.control("task.restoreButton", ofTask: "Label check").label, "Restore")
    }
}
