import KyosakuCore
import SwiftUI

/// A completed task, which can go back to not started or be deleted.
struct CompletedTaskRow: View {
    let task: WorkTask
    let tasks: TasksCoordinator

    @State private var confirmsDelete = false

    var body: some View {
        HStack(spacing: 6) {
            Text(task.name)
                .lineLimit(2)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            if confirmsDelete {
                DeleteConfirmation {
                    tasks.deleteTask(task.id)
                } onCancel: {
                    confirmsDelete = false
                }
            } else {
                Button("Restore", systemImage: "arrow.uturn.backward") {
                    tasks.restoreTask(task.id)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help("Restore")
                .accessibilityIdentifier("task.restoreButton")
                Button("Delete", systemImage: "trash") {
                    confirmsDelete = true
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help("Delete")
                .accessibilityIdentifier("task.deleteButton")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(task.name)
        .accessibilityIdentifier("task.row")
    }
}
