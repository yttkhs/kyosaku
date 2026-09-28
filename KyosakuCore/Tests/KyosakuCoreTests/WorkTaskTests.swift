import Foundation
import KyosakuCore
import Testing

struct WorkTaskTests {
    private let task = WorkTask(name: "Write the report", details: "Section 2", createdAt: .distantPast)

    @Test func startsNotCompletedAtTheFirstRevision() {
        #expect(!task.isCompleted)
        #expect(task.revision == 1)
    }

    @Test func countsARevisionWhenTheNameChanges() {
        let renamed = task.applying(TaskDraft(name: "Write the summary", details: "Section 2"))

        #expect(renamed.name == "Write the summary")
        #expect(renamed.revision == 2)
    }

    @Test func countsARevisionWhenTheDetailsChange() {
        #expect(task.applying(TaskDraft(name: "Write the report", details: "Section 3")).revision == 2)
    }

    @Test func keepsTheRevisionWhenOnlySpacingDiffers() {
        #expect(task.applying(TaskDraft(name: " Write the report ", details: "Section 2\n")) == task)
    }

    @Test func keepsEverythingButTheWording() {
        let done = WorkTask(name: "Old", createdAt: .distantPast, completedAt: .distantFuture)
        let renamed = done.applying(TaskDraft(name: "New"))

        #expect(renamed.id == done.id)
        #expect(renamed.createdAt == done.createdAt)
        #expect(renamed.completedAt == done.completedAt)
    }
}
