import Foundation
import KyosakuCore
import Testing

struct TaskListTests {
    @Test func putsTheNewestTaskNotStartedFirst() {
        let older = task("Older", created: 1)
        let newer = task("Newer", created: 2)

        #expect(TaskList(tasks: [older, newer], activeTaskID: nil).notStarted == [newer, older])
    }

    @Test func keepsTheTaskInProgressApart() {
        let older = task("Older", created: 1)
        let newer = task("Newer", created: 2)

        let list = TaskList(tasks: [older, newer], activeTaskID: older.id)

        #expect(list.active == older)
        #expect(list.notStarted == [newer])
    }

    @Test func putsTheLatestCompletedTaskFirst() {
        let early = task("Early", created: 1, completed: 5)
        let late = task("Late", created: 2, completed: 9)

        let list = TaskList(tasks: [early, late], activeTaskID: nil)

        #expect(list.completed == [late, early])
        #expect(list.notStarted.isEmpty)
    }

    @Test func ignoresATaskInProgressThatIsCompleted() {
        let done = task("Done", created: 1, completed: 2)

        let list = TaskList(tasks: [done], activeTaskID: done.id)

        #expect(list.active == nil)
        #expect(list.completed == [done])
    }

    @Test func ignoresATaskInProgressThatDoesNotExist() {
        let only = task("Only", created: 1)

        let list = TaskList(tasks: [only], activeTaskID: UUID())

        #expect(list.active == nil)
        #expect(list.notStarted == [only])
    }

    @Test func ordersTasksMadeAtTheSameMomentByID() {
        let first = task("First", created: 1)
        let second = task("Second", created: 1)
        let expected = [first, second].sorted { $0.id.uuidString < $1.id.uuidString }

        #expect(TaskList(tasks: [first, second], activeTaskID: nil).notStarted == expected)
        #expect(TaskList(tasks: [second, first], activeTaskID: nil).notStarted == expected)
    }
}

private func task(_ name: String, created: TimeInterval, completed: TimeInterval? = nil) -> WorkTask {
    WorkTask(
        name: name,
        createdAt: Date(timeIntervalSinceReferenceDate: created),
        completedAt: completed.map(Date.init(timeIntervalSinceReferenceDate:))
    )
}
