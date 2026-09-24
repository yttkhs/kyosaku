import XCTest

extension XCUIApplication {
    /// UI tests always drive the Debug build, which is its own app.
    static let kyosakuBundleIdentifier = "io.github.yttkhs.kyosaku.dev"

    /// Launches Kyosaku with its popover content in a window. The arguments must match `LaunchOptions`,
    /// which this test bundle cannot import.
    @MainActor
    static func launchKyosakuForTesting() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-KyosakuUITesting", "-KyosakuMenuContentInWindow"]
        app.launch()
        // While you use another app, macOS may not let Kyosaku come to the front by itself.
        app.activate()
        return app
    }

    /// Adds a task through the form, the way a person would.
    @MainActor
    func addTask(named name: String) {
        XCTAssertTrue(buttons["tasks.newButton"].waitForExistence(timeout: 5))
        buttons["tasks.newButton"].click()
        let field = textFields["taskForm.nameField"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.click()
        field.typeText(name)
        buttons["taskForm.submitButton"].click()
        XCTAssertTrue(taskRow(named: name).waitForExistence(timeout: 5))
    }

    /// The row of the task named `name`, whichever group it is in.
    @MainActor
    func taskRow(named name: String) -> XCUIElement {
        descendants(matching: .any)
            .matching(NSPredicate(format: "identifier == %@ AND label == %@", "task.row", name))
            .firstMatch
    }

    /// A control in the row of the task named `name`.
    @MainActor
    func control(_ identifier: String, ofTask name: String) -> XCUIElement {
        taskRow(named: name).descendants(matching: .any)[identifier]
    }

    /// The names of the rows on screen, from top to bottom.
    @MainActor
    func taskNamesInOrder() -> [String] {
        descendants(matching: .any).matching(identifier: "task.row").allElementsBoundByIndex
            .sorted { $0.frame.minY < $1.frame.minY }
            .map(\.label)
    }
}
