import SwiftUI

/// What a row shows after its trash button, so that one click never deletes a task.
struct DeleteConfirmation: View {
    let onDelete: () -> Void
    let onCancel: () -> Void

    var body: some View {
        Button("Delete", role: .destructive, action: onDelete)
            .accessibilityIdentifier("task.confirmDeleteButton")
        Button("Cancel", action: onCancel)
            .accessibilityIdentifier("task.cancelDeleteButton")
    }
}
