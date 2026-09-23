import SwiftUI

/// Stands in for a tab's real pane until its feature is built.
struct SettingsPlaceholderPane: View {
    let tab: SettingsTab

    var body: some View {
        VStack(spacing: 8) {
            Text(tab.title)
                .font(.title2)
            Text("Coming soon.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("settings.pane.\(tab.rawValue)")
    }
}
