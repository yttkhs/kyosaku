import Foundation

/// A task the user works on. The one in progress is what Kyosaku compares the screen with.
public struct WorkTask: Identifiable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    // Not `description`, which `CustomStringConvertible` already claims.
    public var details: String
    public let createdAt: Date
    public var completedAt: Date?
    // Grows with every change of wording, so relevance judged for the old wording expires.
    public var revision: Int

    public init(
        id: UUID = UUID(),
        name: String,
        details: String = "",
        createdAt: Date,
        completedAt: Date? = nil,
        revision: Int = 1
    ) {
        self.id = id
        self.name = name
        self.details = details
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.revision = revision
    }

    public var isCompleted: Bool { completedAt != nil }

    public func applying(_ draft: TaskDraft) -> WorkTask {
        let wording = draft.normalized
        guard wording.name != name || wording.details != details else { return self }
        var task = self
        task.name = wording.name
        task.details = wording.details
        task.revision += 1
        return task
    }
}
