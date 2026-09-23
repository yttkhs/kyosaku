import Foundation

/// How this launch was started, read once from the process arguments and environment.
struct LaunchOptions {
    static let uiTestingArgument = "-KyosakuUITesting"
    static let menuContentInWindowArgument = "-KyosakuMenuContentInWindow"
    static let hostingUnitTestsVariable = "KYOSAKU_HOSTING_UNIT_TESTS"

    let isUITesting: Bool
    let showsMenuContentInWindow: Bool
    let isHostingUnitTests: Bool

    init(arguments: [String], environment: [String: String]) {
        isUITesting = arguments.contains(Self.uiTestingArgument)
        showsMenuContentInWindow = arguments.contains(Self.menuContentInWindowArgument)
        isHostingUnitTests = environment[Self.hostingUnitTestsVariable] == "1"
    }

    static var current: LaunchOptions {
        LaunchOptions(
            arguments: ProcessInfo.processInfo.arguments, environment: ProcessInfo.processInfo.environment)
    }
}
