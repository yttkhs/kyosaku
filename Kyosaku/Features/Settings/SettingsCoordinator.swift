import AppKit

/// Opens the Settings window, or brings it forward on the requested tab when it is already open.
final class SettingsCoordinator {
    private let window: AppWindowController
    private weak var tabs: SettingsTabViewController?

    init(activationPolicy: ActivationPolicy) {
        window = AppWindowController(
            title: String(localized: "Settings"),
            contentSize: CGSize(width: 600, height: 400),
            toolbarStyle: .preference,
            activationPolicy: activationPolicy
        )
    }

    func showSettings(tab: SettingsTab? = nil) {
        if let tab {
            tabs?.select(tab)
        }
        window.show(viewController: makeTabs(selecting: tab ?? .general))
    }

    private func makeTabs(selecting tab: SettingsTab) -> NSViewController {
        let tabs = SettingsTabViewController(selecting: tab)
        self.tabs = tabs
        return tabs
    }
}
