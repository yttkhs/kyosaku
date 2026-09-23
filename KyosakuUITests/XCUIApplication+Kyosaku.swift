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
        return app
    }
}
