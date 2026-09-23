import KyosakuCore
import Observation

/// Owns every long-lived object in the app.
@Observable
final class AppRoot {
    private(set) var status: MonitoringStatus = .idle

    let activationPolicy = ActivationPolicy()
    @ObservationIgnored private(set) lazy var settingsCoordinator = SettingsCoordinator(
        activationPolicy: activationPolicy
    )
}
