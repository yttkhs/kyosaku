import Foundation
import KyosakuCore
import Testing

@testable import Kyosaku

struct TaskStoreTests {
    @Test func addsTasksNewestFirst() throws {
        try ScratchStore.use { scratch in
            let store = scratch.open()
            store.add(TaskDraft(name: "Older"))
            store.add(TaskDraft(name: "Newer"))

            #expect(store.list.notStarted.map(\.name) == ["Newer", "Older"])
        }
    }

    @Test func refusesATaskWithoutAName() throws {
        try ScratchStore.use { scratch in
            let store = scratch.open()

            #expect(store.add(TaskDraft(name: "  ")) == nil)
            #expect(store.list == .empty)
        }
    }

    @Test func keepsTasksAndTheTaskInProgressAfterReopening() throws {
        try ScratchStore.use { scratch in
            let id = try #require(scratch.open().add(TaskDraft(name: "Write", details: "Section 2"))).id
            scratch.open().setActive(id)

            let reopened = scratch.open()

            #expect(reopened.list.active?.id == id)
            #expect(reopened.list.active?.details == "Section 2")
        }
    }

    @Test func savesARewordedTaskAsANewRevision() throws {
        try ScratchStore.use { scratch in
            let id = try #require(scratch.open().add(TaskDraft(name: "Draft"))).id
            scratch.open().update(id, with: TaskDraft(name: "Final"))

            let task = try #require(scratch.open().list.notStarted.first)

            #expect(task.name == "Final")
            #expect(task.revision == 2)
        }
    }

    @Test func workingOnAnotherTaskStopsTheFirst() throws {
        try ScratchStore.use { scratch in
            let store = scratch.open()
            let first = try #require(store.add(TaskDraft(name: "First"))).id
            let second = try #require(store.add(TaskDraft(name: "Second"))).id

            store.setActive(first)
            store.setActive(second)

            #expect(store.list.active?.id == second)
            #expect(store.list.notStarted.map(\.id) == [first])
        }
    }

    @Test func completingTheTaskInProgressStopsWork() throws {
        try ScratchStore.use { scratch in
            let store = scratch.open()
            let id = try #require(store.add(TaskDraft(name: "Ship"))).id
            store.setActive(id)

            store.complete(id)

            #expect(store.list.active == nil)
            #expect(store.list.completed.map(\.id) == [id])
            #expect(scratch.defaults.string(forKey: TaskStore.activeTaskIDKey) == nil)
        }
    }

    @Test func cannotWorkOnACompletedTask() throws {
        try ScratchStore.use { scratch in
            let store = scratch.open()
            let id = try #require(store.add(TaskDraft(name: "Done"))).id
            store.complete(id)

            store.setActive(id)

            #expect(store.list.active == nil)
        }
    }

    @Test func restoringPutsATaskBackAmongNotStarted() throws {
        try ScratchStore.use { scratch in
            let store = scratch.open()
            let id = try #require(store.add(TaskDraft(name: "Again"))).id
            store.complete(id)

            store.restore(id)

            #expect(store.list.notStarted.map(\.id) == [id])
            #expect(store.list.completed.isEmpty)
        }
    }

    @Test func deletingTheTaskInProgressStopsWork() throws {
        try ScratchStore.use { scratch in
            let store = scratch.open()
            let id = try #require(store.add(TaskDraft(name: "Drop"))).id
            store.setActive(id)

            store.delete(id)

            #expect(scratch.open().list == .empty)
            #expect(scratch.defaults.string(forKey: TaskStore.activeTaskIDKey) == nil)
        }
    }

    @Test func forgetsATaskInProgressThatNoLongerExists() throws {
        try ScratchStore.use { scratch in
            scratch.defaults.set(UUID().uuidString, forKey: TaskStore.activeTaskIDKey)

            #expect(scratch.open().list.active == nil)
            #expect(scratch.defaults.string(forKey: TaskStore.activeTaskIDKey) == nil)
        }
    }

    @Test func keepsTheTaskInProgressWhenTheStoreCannotBeRead() throws {
        try ScratchStore.use { scratch in
            let id = UUID().uuidString
            scratch.defaults.set(id, forKey: TaskStore.activeTaskIDKey)

            let store = TaskStore(
                container: Storage.openInMemory(), defaults: scratch.defaults, isSavingUnavailable: true)

            #expect(store.list.active == nil)
            #expect(scratch.defaults.string(forKey: TaskStore.activeTaskIDKey) == id)
        }
    }

    @Test func keepsWorkingInMemoryWhenTheFileIsNotAStore() throws {
        try ScratchStore.use { scratch in
            try FileManager.default.createDirectory(
                at: scratch.url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let garbage = Data("not a database".utf8)
            try garbage.write(to: scratch.url)

            let opened = Storage.open(at: scratch.url)
            let store = TaskStore(
                container: opened.container, defaults: scratch.defaults,
                isSavingUnavailable: opened.isSavingUnavailable)
            store.add(TaskDraft(name: "Kept in memory"))

            #expect(store.isSavingUnavailable)
            #expect(store.list.notStarted.map(\.name) == ["Kept in memory"])
            #expect(try Data(contentsOf: scratch.url) == garbage)
        }
    }
}
