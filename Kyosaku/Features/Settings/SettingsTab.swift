import Foundation

/// The Settings window's tabs, in toolbar order.
enum SettingsTab: String, CaseIterable {
    case general
    case templates
    case privacy
    case permissions
    case stats

    var title: String {
        switch self {
        case .general: String(localized: "General")
        case .templates: String(localized: "Templates")
        case .privacy: String(localized: "Privacy")
        case .permissions: String(localized: "Permissions")
        case .stats: String(localized: "Stats")
        }
    }

    var symbolName: String {
        switch self {
        case .general: "gearshape"
        case .templates: "list.bullet.rectangle"
        case .privacy: "hand.raised"
        case .permissions: "lock.shield"
        case .stats: "chart.bar"
        }
    }
}
