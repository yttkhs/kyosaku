import KyosakuCore
import SwiftUI

/// Adds or edits a task, in place of the list.
struct TaskForm: View {
    private enum Field {
        case name, details
    }

    let title: LocalizedStringKey
    let submitTitle: LocalizedStringKey
    let onSubmit: (TaskDraft) -> Void
    let onCancel: () -> Void

    @State private var draft: TaskDraft
    @FocusState private var focusedField: Field?

    init(
        title: LocalizedStringKey,
        submitTitle: LocalizedStringKey,
        draft: TaskDraft = TaskDraft(),
        onSubmit: @escaping (TaskDraft) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.submitTitle = submitTitle
        self.onSubmit = onSubmit
        self.onCancel = onCancel
        _draft = State(initialValue: draft)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            TextField("Task name", text: $draft.name)
                .focused($focusedField, equals: .name)
                .onSubmit(submit)
                .onChange(of: draft.name) { _, name in
                    draft.name = Self.limited(name, to: TaskDraft.nameLimit)
                }
                .accessibilityIdentifier("taskForm.nameField")
            RemainingCount(text: draft.name, limit: TaskDraft.nameLimit)
            TextEditor(text: $draft.details)
                .focused($focusedField, equals: .details)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(4)
                .frame(height: 84)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
                .overlay(alignment: .topLeading) {
                    if draft.details.isEmpty {
                        Text("Description")
                            .foregroundStyle(.tertiary)
                            .padding(.leading, 9)
                            .padding(.top, 4)
                            .allowsHitTesting(false)
                    }
                }
                .onChange(of: draft.details) { _, details in
                    draft.details = Self.limited(details, to: TaskDraft.detailsLimit)
                }
                .accessibilityIdentifier("taskForm.detailsField")
            Text("Kyosaku uses this to tell what's related.")
                .font(.caption)
                .foregroundStyle(.secondary)
            RemainingCount(text: draft.details, limit: TaskDraft.detailsLimit)
            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                    .keyboardShortcut(.cancelAction)
                    .accessibilityIdentifier("taskForm.cancelButton")
                Button(submitTitle, action: submit)
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(!draft.canSave)
                    .accessibilityIdentifier("taskForm.submitButton")
            }
        }
        .onAppear { focusedField = .name }
    }

    private func submit() {
        guard draft.canSave else { return }
        onSubmit(draft)
    }

    // Cutting text that an input method is still composing would throw the conversion away.
    private static func limited(_ text: String, to limit: Int) -> String {
        TextComposition.isActive ? text : TaskDraft.clipped(text, limit: limit)
    }

    private struct RemainingCount: View {
        let text: String
        let limit: Int

        var body: some View {
            if let remaining = TaskDraft.remainingCount(of: text, limit: limit) {
                Text("\(remaining) left")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}
