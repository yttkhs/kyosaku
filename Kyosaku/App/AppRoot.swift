import KyosakuCore
import SwiftUI

/// Owns every long-lived object in the app; `start()` is the whole launch sequence.
@Observable
final class AppRoot {
    let launch: LaunchOptions
    private(set) var status: MonitoringStatus = .idle

    let activationPolicy = ActivationPolicy()
    @ObservationIgnored private(set) lazy var settingsCoordinator = SettingsCoordinator(
        activationPolicy: activationPolicy
    )
    @ObservationIgnored private(set) lazy var onboardingCoordinator = OnboardingCoordinator(
        state: OnboardingState(defaults: .standard),
        activationPolicy: activationPolicy
    )
    @ObservationIgnored private lazy var menuContentWindow = AppWindowController(
        title: "Kyosaku",
        contentSize: CGSize(width: 300, height: 160),
        activationPolicy: activationPolicy
    )

    init(launch: LaunchOptions) {
        self.launch = launch
    }

    func start() {
        if launch.showsMenuContentInWindow {
            menuContentWindow.show(rootView: MenuContentView().environment(self))
        }
        if !launch.isUITesting {
            onboardingCoordinator.showIfNeeded()
        }
    }
}
