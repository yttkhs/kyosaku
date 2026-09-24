import KyosakuCore
import SwiftUI

/// The task in progress, then the tasks not started yet, then the completed ones.
struct TaskListView: View {
    let tasks: TasksCoordinator
    @Binding var showsCompleted: Bool
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
                        TaskRow(task: active, isActive: true, tasks: tasks, onEdit: onEdit)
                        Divider()
                    }
                    ForEach(tasks.list.notStarted) { task in
                        TaskRow(task: task, isActive: false, tasks: tasks, onEdit: onEdit)
                    }
                    if !tasks.list.completed.isEmpty {
                        completedSection
                    }
                }
            }
            // Grows with the tasks up to this height, then scrolls.
            .frame(maxHeight: 360)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder private var completedSection: some View {
        Button {
            showsCompleted.toggle()
        } label: {
            Label(
                "Completed (\(tasks.list.completed.count))",
                systemImage: showsCompleted ? "chevron.down" : "chevron.right")
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("tasks.completedToggle")
        if showsCompleted {
            ForEach(tasks.list.completed) { task in
                CompletedTaskRow(task: task, tasks: tasks)
            }
        }
    }
}
