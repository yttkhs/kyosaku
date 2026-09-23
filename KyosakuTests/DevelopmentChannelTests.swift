import Foundation
import Testing

struct DevelopmentChannelTests {
    @Test func debugBuildsUseTheirOwnBundleIdentifier() {
        #expect(Bundle.main.bundleIdentifier == "io.github.yttkhs.kyosaku.dev")
    }

    @Test func debugBuildsUseTheirOwnName() {
        #expect(Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String == "Kyosaku Dev")
    }
}
