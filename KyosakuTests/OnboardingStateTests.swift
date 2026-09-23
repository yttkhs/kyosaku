import Foundation
import Testing

@testable import Kyosaku

struct OnboardingStateTests {
    @Test func startsUnseen() throws {
        try withScratchDefaults { defaults in
            #expect(!OnboardingState(defaults: defaults).hasSeenOnboarding)
        }
    }

    @Test func remembersThatItWasSeen() throws {
        try withScratchDefaults { defaults in
            OnboardingState(defaults: defaults).markSeen()

            #expect(OnboardingState(defaults: defaults).hasSeenOnboarding)
        }
    }
}

/// Runs `body` with defaults nobody else reads, and deletes them afterwards.
private func withScratchDefaults(_ body: (UserDefaults) throws -> Void) throws {
    let suiteName = "io.github.yttkhs.kyosaku.tests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }
    try body(defaults)
}
