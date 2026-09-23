import Foundation

/// Whether the first-launch welcome has been shown.
struct OnboardingState {
    static let hasSeenOnboardingKey = "hasSeenOnboarding"

    private let defaults: UserDefaults

    init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    var hasSeenOnboarding: Bool {
        defaults.bool(forKey: Self.hasSeenOnboardingKey)
    }

    func markSeen() {
        defaults.set(true, forKey: Self.hasSeenOnboardingKey)
    }
}
