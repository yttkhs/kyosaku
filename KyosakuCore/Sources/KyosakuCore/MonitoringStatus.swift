/// What the menu bar icon tells the user about monitoring.
public enum MonitoringStatus: Sendable, CaseIterable {
    /// No task is in progress, so nothing is monitored.
    case idle
    /// A task is in progress and the screen is being checked against it.
    case monitoring
    /// The distraction meter reached the nudge threshold.
    case nudging
    /// Monitoring needs the user first, for example a missing permission or Apple Intelligence being off.
    case needsAttention
}
