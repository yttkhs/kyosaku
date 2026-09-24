import KyosakuCore
import SwiftUI

/// A task in progress or not started yet.
struct TaskRow: View {
    let task: WorkTask
    let isActive: Bool
    let tasks: TasksCoordinator
    let onEdit: (WorkTask) -> Void

    @State private var confirmsDelete = false

    var body: some View {
        HStack(spacing: 6) {
            Button {
                onEdit(task)
            } label: {
                Text(task.name)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("task.nameButton")
            if confirmsDelete {
                DeleteConfirmation {
                    tasks.deleteTask(task.id)
                } onCancel: {
                    confirmsDelete = false
                }
            } else {
                Toggle("In Progress", isOn: inProgress)
                    .toggleStyle(.switch)
                    .controlSize(.mini)
                    .labelsHidden()
                    .accessibilityIdentifier("task.activeToggle")
                Button("Complete", systemImage: "checkmark.circle") {
                    tasks.completeTask(task.id)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help("Complete")
                .accessibilityIdentifier("task.completeButton")
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

    private var inProgress: Binding<Bool> {
        Binding {
            isActive
        } set: { isOn in
            if isOn {
                tasks.startWorking(on: task.id)
            } else {
                tasks.stopWorking()
            }
        }
    }
}
