import AppKit
import SwiftUI

/// The Settings window's content: one toolbar tab per `SettingsTab`, each hosting a SwiftUI pane.
final class SettingsTabViewController: NSTabViewController {
    init(selecting tab: SettingsTab) {
        super.init(nibName: nil, bundle: nil)
        tabStyle = .toolbar
        for tab in SettingsTab.allCases {
            let pane = NSHostingController(rootView: SettingsPlaceholderPane(tab: tab))
            pane.sizingOptions = []
            pane.title = tab.title
            let item = NSTabViewItem(viewController: pane)
            item.identifier = tab.rawValue
            item.label = tab.title
            item.image = NSImage(systemSymbolName: tab.symbolName, accessibilityDescription: tab.title)
            addTabViewItem(item)
        }
        select(tab)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    func select(_ tab: SettingsTab) {
        guard let index = SettingsTab.allCases.firstIndex(of: tab) else { return }
        selectedTabViewItemIndex = index
    }
}
