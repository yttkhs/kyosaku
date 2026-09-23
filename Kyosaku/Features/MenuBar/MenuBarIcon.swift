import KyosakuCore

/// Picks the menu bar symbol for each status. Stock symbols stand in until Kyosaku has its own.
enum MenuBarIcon {
    static func symbolName(for status: MonitoringStatus) -> String {
        switch status {
        case .idle: "app"
        case .monitoring: "app.fill"
        case .nudging: "app.badge.fill"
        case .needsAttention: "exclamationmark.triangle"
        }
    }
}
