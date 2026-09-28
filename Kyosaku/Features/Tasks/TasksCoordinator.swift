import Foundation
import KyosakuCore

/// What the popover can do with tasks. Starting work is also where monitoring will start.
final class TasksCoordinator {
    private let store: TaskStore

    init(store: TaskStore) {
        self.store = store
    }

    var list: TaskList { store.list }
    var isSavingUnavailable: Bool { store.isSavingUnavailable }

    func addTask(_ draft: TaskDraft) {
        store.add(draft)
    }

    func updateTask(_ id: UUID, with draft: TaskDraft) {
        store.update(id, with: draft)
    }

    func startWorking(on id: UUID) {
        store.setActive(id)
    }

    func stopWorking() {
        store.setActive(nil)
    }

    func completeTask(_ id: UUID) {
        store.complete(id)
    }

    func restoreTask(_ id: UUID) {
        store.restore(id)
    }

    func deleteTask(_ id: UUID) {
        store.delete(id)
    }
}
