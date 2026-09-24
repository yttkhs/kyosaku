import XCTest

final class OnboardingUITests: XCTestCase {
    @MainActor
    func testUITestingLaunchesSkipTheWelcome() {
        let app = XCUIApplication.launchKyosakuForTesting()
        XCTAssertTrue(app.buttons["tasks.newButton"].waitForExistence(timeout: 5))

        XCTAssertFalse(app.windows["Welcome to Kyosaku"].exists)
        XCTAssertFalse(app.buttons["onboarding.getStartedButton"].exists)
    }
}
