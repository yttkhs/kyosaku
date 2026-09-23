import SwiftUI

@main
struct KyosakuApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuContentView()
                .environment(appDelegate.root)
        } label: {
            Image(systemName: MenuBarIcon.symbolName(for: appDelegate.root.status))
                .accessibilityLabel(Text(verbatim: "Kyosaku"))
        }
        .menuBarExtraStyle(.window)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings…") {
                    appDelegate.root.settingsCoordinator.showSettings()
                }
                .keyboardShortcut(",")
            }
        }
    }
}
