import Testing

@testable import Kyosaku

struct LaunchOptionsTests {
    @Test func turnsEverythingOffByDefault() {
        let options = LaunchOptions(
            arguments: ["/Applications/Kyosaku.app/Contents/MacOS/Kyosaku"], environment: [:])

        #expect(!options.isUITesting)
        #expect(!options.showsMenuContentInWindow)
        #expect(!options.isHostingUnitTests)
    }

    @Test func readsTheUITestingArguments() {
        let options = LaunchOptions(
            arguments: ["Kyosaku", "-KyosakuUITesting", "-KyosakuMenuContentInWindow"],
            environment: [:]
        )

        #expect(options.isUITesting)
        #expect(options.showsMenuContentInWindow)
    }

    @Test func treatsOnlyOneAsTheHostingFlag() {
        let variable = "KYOSAKU_HOSTING_UNIT_TESTS"

        #expect(LaunchOptions(arguments: [], environment: [variable: "1"]).isHostingUnitTests)
        #expect(!LaunchOptions(arguments: [], environment: [variable: "0"]).isHostingUnitTests)
        #expect(!LaunchOptions(arguments: [], environment: [variable: "true"]).isHostingUnitTests)
    }

    @Test func runsTheseTestsWithTheHostingFlagSet() {
        // The scheme sets it; without it, every test run would launch the host app's real windows.
        #expect(LaunchOptions.current.isHostingUnitTests)
    }
}
