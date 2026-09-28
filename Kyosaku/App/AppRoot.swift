import KyosakuCore
import SwiftUI

/// Owns every long-lived object in the app; `start()` is the whole launch sequence.
@Observable
final class AppRoot {
    let launch: LaunchOptions
    // Observed, so that the menu bar icon redraws once start() has opened the tasks.
    private(set) var tasks: TasksCoordinator?

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
        contentSize: CGSize(width: 300, height: 520),
        activationPolicy: activationPolicy
    )

    init(launch: LaunchOptions) {
        self.launch = launch
    }

    var status: MonitoringStatus {
        tasks?.list.active == nil ? .idle : .monitoring
    }

    func start() {
        tasks = TasksCoordinator(store: makeTaskStore())
        if launch.showsMenuContentInWindow {
            menuContentWindow.show(rootView: MenuContentView().environment(self))
        }
        if !launch.isUITesting {
            onboardingCoordinator.showIfNeeded()
        }
    }

    private func makeTaskStore() -> TaskStore {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "Kyosaku"
        guard !launch.isUITesting else {
            let defaults = Self.scratchDefaults(bundleIdentifier)
            return TaskStore(container: Storage.openInMemory(), defaults: defaults)
        }
        let opened = Storage.open(at: Storage.url(bundleIdentifier: bundleIdentifier))
        return TaskStore(
            container: opened.container, defaults: .standard, isSavingUnavailable: opened.isSavingUnavailable)
    }

    // UI tests start from nothing every time, and never touch the Dev app's own tasks.
    private static func scratchDefaults(_ bundleIdentifier: String) -> UserDefaults {
        let suiteName = "\(bundleIdentifier).uitesting"
        // Only the app's own ID and the global domain are refused, so this name always works.
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
