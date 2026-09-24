import KyosakuCore
import SwiftUI

/// The task in progress, then the tasks not started yet.
struct TaskListView: View {
    let tasks: TasksCoordinator
    let onNewTask: () -> Void
    let onEdit: (WorkTask) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if tasks.isSavingUnavailable {
                Label("Tasks can't be saved right now.", systemImage: "exclamationmark.triangle")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("tasks.storageWarning")
            }
            Button("New Task", systemImage: "plus", action: onNewTask)
                .buttonStyle(.borderless)
                .accessibilityIdentifier("tasks.newButton")
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    if let active = tasks.list.active {
                        TaskRow(task: active, onEdit: onEdit)
                        Divider()
                    }
                    ForEach(tasks.list.notStarted) { task in
                        TaskRow(task: task, onEdit: onEdit)
                    }
                }
            }
            // Grows with the tasks up to this height, then scrolls.
            .frame(maxHeight: 360)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
