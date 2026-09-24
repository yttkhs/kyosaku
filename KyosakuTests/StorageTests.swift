import Foundation
import KyosakuCore
import SwiftData
import Testing

@testable import Kyosaku

struct StorageTests {
    @Test func keepsTasksAfterReopening() throws {
        try withScratchFolder { folder in
            let url = folder.appending(path: "Kyosaku.store")
            let task = WorkTask(name: "Write", details: "Section 2", createdAt: .now)
            let context = ModelContext(Storage.open(at: url).container)
            context.insert(WorkTaskRecord(task))
            try context.save()

            let reopened = ModelContext(Storage.open(at: url).container)

            #expect(try reopened.fetch(FetchDescriptor<WorkTaskRecord>()).map(\.task) == [task])
        }
    }

    @Test func keepsWorkingInMemoryWhenTheFileIsNotAStore() throws {
        try withScratchFolder { folder in
            let url = folder.appending(path: "Kyosaku.store")
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let garbage = Data("not a database".utf8)
            try garbage.write(to: url)

            let opened = Storage.open(at: url)
            let context = ModelContext(opened.container)
            context.insert(WorkTaskRecord(WorkTask(name: "Kept in memory", createdAt: .now)))
            try context.save()

            #expect(opened.isSavingUnavailable)
            #expect(try context.fetchCount(FetchDescriptor<WorkTaskRecord>()) == 1)
            #expect(try Data(contentsOf: url) == garbage)
        }
    }

    @Test func keepsEachAppsDataInAFolderOfItsOwn() {
        let url = Storage.url(bundleIdentifier: "io.github.yttkhs.kyosaku.dev")

        #expect(url.lastPathComponent == "Kyosaku.store")
        #expect(url.deletingLastPathComponent().lastPathComponent == "io.github.yttkhs.kyosaku.dev")
        #expect(url.path(percentEncoded: false).contains("/Library/Application Support/"))
    }
}
