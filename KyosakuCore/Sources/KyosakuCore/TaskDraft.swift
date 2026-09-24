import Foundation

/// The wording typed into the task form, and how it is cleaned up before it is saved.
public struct TaskDraft: Equatable, Sendable {
    // The prompt sends the model at most this much, so the form stops here too.
    public static let nameLimit = 100
    public static let detailsLimit = 500

    public var name: String
    public var details: String

    public init(name: String = "", details: String = "") {
        self.name = name
        self.details = details
    }

    public init(_ task: WorkTask) {
        self.init(name: task.name, details: task.details)
    }

    /// Trimmed, with the name on one line, and both within their limits.
    public var normalized: TaskDraft {
        let oneLineName = name.split(whereSeparator: \.isNewline).joined(separator: " ")
        return TaskDraft(
            name: Self.fitted(oneLineName, limit: Self.nameLimit),
            details: Self.fitted(details, limit: Self.detailsLimit)
        )
    }

    public var canSave: Bool { !normalized.name.isEmpty }

    /// `text` cut at `limit`, counting each character a person sees as one.
    public static func clipped(_ text: String, limit: Int) -> String {
        text.count > limit ? String(text.prefix(limit)) : text
    }

    /// How many more characters fit, once `text` is past 80% of `limit`.
    public static func remainingCount(of text: String, limit: Int) -> Int? {
        text.count * 5 > limit * 4 ? max(limit - text.count, 0) : nil
    }

    private static func fitted(_ text: String, limit: Int) -> String {
        String(text.trimmingCharacters(in: .whitespacesAndNewlines).prefix(limit))
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
