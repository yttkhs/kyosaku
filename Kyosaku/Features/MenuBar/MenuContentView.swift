import SwiftUI

/// The menu bar popover. The task list replaces the placeholder once it is built.
struct MenuContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tasks will appear here.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, minHeight: 80)
                .accessibilityIdentifier("menu.placeholder")
            Divider()
            HStack {
                Spacer()
                Button("Quit Kyosaku") {
                    NSApp.terminate(nil)
                }
                .accessibilityIdentifier("menu.quitButton")
            }
        }
        .padding()
        .frame(width: 300)
    }
}
