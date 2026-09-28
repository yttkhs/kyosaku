import Foundation

/// The popover's three groups of tasks, each in the order it is shown.
public struct TaskList: Equatable, Sendable {
    public static let empty = TaskList(tasks: [], activeTaskID: nil)

    public let active: WorkTask?
    public let notStarted: [WorkTask]
    public let completed: [WorkTask]

    public init(tasks: [WorkTask], activeTaskID: UUID?) {
        let active = tasks.first { $0.id == activeTaskID && !$0.isCompleted }
        let waiting = tasks.filter { !$0.isCompleted && $0.id != active?.id }
        let done = tasks.filter(\.isCompleted)
        self.active = active
        notStarted = waiting.sorted(by: Self.newestFirst(\.createdAt))
        completed = done.sorted(by: Self.newestFirst { $0.completedAt ?? .distantPast })
    }

    // Ties fall back to the ID, so the same tasks always come out in the same order.
    private static func newestFirst(_ date: @escaping (WorkTask) -> Date) -> (WorkTask, WorkTask) -> Bool {
        { lhs, rhs in
            date(lhs) != date(rhs) ? date(lhs) > date(rhs) : lhs.id.uuidString < rhs.id.uuidString
        }
    }
}
