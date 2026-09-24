import Foundation
import KyosakuCore
import SwiftData
import os

/// Keeps the tasks and the one in progress, and publishes them as a `TaskList`.
@Observable
final class TaskStore {
    static let activeTaskIDKey = "activeTaskID"

    private(set) var list = TaskList.empty
    private(set) var isSavingUnavailable: Bool

    private let context: ModelContext
    private let defaults: UserDefaults
    private let now: () -> Date

    init(
        container: ModelContainer,
        defaults: UserDefaults,
        isSavingUnavailable: Bool = false,
        now: @escaping () -> Date = { .now }
    ) {
        context = ModelContext(container)
        context.autosaveEnabled = false
        self.defaults = defaults
        self.isSavingUnavailable = isSavingUnavailable
        self.now = now
        refresh()
        // A store that could not be read may still hold the task, so it stays in progress.
        if !self.isSavingUnavailable, list.active == nil, activeTaskID != nil {
            activeTaskID = nil
        }
    }

    @discardableResult
    func add(_ draft: TaskDraft) -> WorkTask? {
        guard draft.canSave else { return nil }
        let wording = draft.normalized
        let task = WorkTask(name: wording.name, details: wording.details, createdAt: now())
        context.insert(WorkTaskRecord(task))
        saveAndRefresh()
        return task
    }

    func update(_ id: UUID, with draft: TaskDraft) {
        guard draft.canSave, let record = record(id) else { return }
        let task = record.task.applying(draft)
        guard task != record.task else { return }
        record.update(from: task)
        saveAndRefresh()
    }

    func complete(_ id: UUID) {
        guard let record = record(id), record.completedAt == nil else { return }
        record.completedAt = now()
        if activeTaskID == id {
            activeTaskID = nil
        }
        saveAndRefresh()
    }

    func restore(_ id: UUID) {
        guard let record = record(id), record.completedAt != nil else { return }
        record.completedAt = nil
        saveAndRefresh()
    }

    func delete(_ id: UUID) {
        guard let record = record(id) else { return }
        context.delete(record)
        if activeTaskID == id {
            activeTaskID = nil
        }
        saveAndRefresh()
    }

    /// Makes `id` the task in progress, or leaves no task in progress when `id` is nil.
    func setActive(_ id: UUID?) {
        if let id {
            guard let record = record(id), record.completedAt == nil else { return }
        }
        activeTaskID = id
        refresh()
    }

    private var activeTaskID: UUID? {
        get { defaults.string(forKey: Self.activeTaskIDKey).flatMap(UUID.init(uuidString:)) }
        set {
            if let newValue {
                defaults.set(newValue.uuidString, forKey: Self.activeTaskIDKey)
            } else {
                defaults.removeObject(forKey: Self.activeTaskIDKey)
            }
        }
    }

    private func record(_ id: UUID) -> WorkTaskRecord? {
        var descriptor = FetchDescriptor<WorkTaskRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    private func saveAndRefresh() {
        do {
            try context.save()
        } catch {
            // The change stays in memory, so the popover still shows it; the warning says it isn't saved.
            report(error)
        }
        refresh()
    }

    private func refresh() {
        do {
            let tasks = try context.fetch(FetchDescriptor<WorkTaskRecord>()).map(\.task)
            list = TaskList(tasks: tasks, activeTaskID: activeTaskID)
        } catch {
            report(error)
        }
    }

    private func report(_ error: any Error) {
        isSavingUnavailable = true
        let nsError = error as NSError
        // Only the kind of error: task names and details never go to the system log.
        Self.logger.error("Saving tasks failed: \(nsError.domain, privacy: .public) \(nsError.code)")
    }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Kyosaku", category: "tasks")
}
