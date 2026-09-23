import AppKit

/// Shows the first-launch welcome once.
final class OnboardingCoordinator {
    private let window: AppWindowController
    private let state: OnboardingState

    init(state: OnboardingState, activationPolicy: ActivationPolicy) {
        self.state = state
        window = AppWindowController(
            title: String(localized: "Welcome to Kyosaku"),
            contentSize: CGSize(width: 440, height: 260),
            activationPolicy: activationPolicy
        )
    }

    func showIfNeeded() {
        guard !state.hasSeenOnboarding else { return }
        // Recorded when shown, so quitting halfway still keeps the welcome to one time.
        state.markSeen()
        window.show(rootView: OnboardingView { [weak self] in self?.finish() })
    }

    func finish() {
        window.close()
    }
}
