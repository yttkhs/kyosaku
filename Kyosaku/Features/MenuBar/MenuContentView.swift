import KyosakuCore
import SwiftUI

/// The menu bar popover: the task list, or the form that adds or edits a task.
struct MenuContentView: View {
    private enum Screen: Equatable {
        case list
        case newTask
        case edit(WorkTask)
    }

    @Environment(AppRoot.self) private var root
    @State private var screen = Screen.list
    @State private var showsCompleted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let tasks = root.tasks {
                switch screen {
                case .list:
                    TaskListView(
                        tasks: tasks,
                        showsCompleted: $showsCompleted,
                        onNewTask: { screen = .newTask },
                        onEdit: { screen = .edit($0) }
                    )
                case .newTask:
                    TaskForm(title: "New Task", submitTitle: "Add") { draft in
                        leave(.newTask) { tasks.addTask(draft) }
                    } onCancel: {
                        screen = .list
                    }
                case .edit(let task):
                    TaskForm(title: "Edit Task", submitTitle: "Save", draft: TaskDraft(task)) { draft in
                        leave(.edit(task)) { tasks.updateTask(task.id, with: draft) }
                    } onCancel: {
                        screen = .list
                    }
                }
            }
            Divider()
            HStack {
                Button("Settings…") {
                    root.settingsCoordinator.showSettings()
                }
                .accessibilityIdentifier("menu.settingsButton")
                Spacer()
                Button("Quit Kyosaku") {
                    NSApp.terminate(nil)
                }
                .accessibilityIdentifier("menu.quitButton")
            }
        }
        .padding()
        .frame(width: 300)
    }

    // A second Return or click that arrives before the list is back must not save the task twice.
    private func leave(_ form: Screen, saving save: () -> Void) {
        guard screen == form else { return }
        screen = .list
        save()
    }
}
