import KyosakuCore
import Testing

@testable import Kyosaku

struct AppRootTests {
    @Test func opensNoTasksBeforeStart() {
        let root = AppRoot(launch: LaunchOptions(arguments: [], environment: [:]))

        #expect(root.tasks == nil)
        #expect(root.status == .idle)
    }

    @Test func showsMonitoringWhileATaskIsInProgress() throws {
        let root = AppRoot(launch: uiTestingLaunch)
        root.start()
        let tasks = try #require(root.tasks)
        tasks.addTask(TaskDraft(name: "Write"))
        let task = try #require(tasks.list.notStarted.first)
        #expect(root.status == .idle)

        tasks.startWorking(on: task.id)

        #expect(root.status == .monitoring)
    }

    @Test func startsEveryUITestingLaunchWithNoTasks() throws {
        let first = AppRoot(launch: uiTestingLaunch)
        first.start()
        let tasks = try #require(first.tasks)
        tasks.addTask(TaskDraft(name: "Left over"))
        let task = try #require(tasks.list.notStarted.first)
        tasks.startWorking(on: task.id)

        let second = AppRoot(launch: uiTestingLaunch)
        second.start()

        #expect(try #require(second.tasks).list == .empty)
    }
}

private let uiTestingLaunch = LaunchOptions(arguments: [LaunchOptions.uiTestingArgument], environment: [:])
