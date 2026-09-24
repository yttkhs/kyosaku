import KyosakuCore
import SwiftUI

/// A task in progress or not started yet.
struct TaskRow: View {
    let task: WorkTask
    let onEdit: (WorkTask) -> Void

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
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(task.name)
        .accessibilityIdentifier("task.row")
    }
}
