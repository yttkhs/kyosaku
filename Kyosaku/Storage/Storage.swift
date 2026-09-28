import Foundation
import SwiftData
import os

/// Opens the SwiftData store that every feature keeps its data in.
enum Storage {
    struct Opened {
        let container: ModelContainer
        let isSavingUnavailable: Bool
    }

    static func url(bundleIdentifier: String) -> URL {
        URL.applicationSupportDirectory
            .appending(path: bundleIdentifier, directoryHint: .isDirectory)
            .appending(path: "Kyosaku.store")
    }

    static func open(at url: URL) -> Opened {
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            let configuration = ModelConfiguration(schema: schema, url: url)
            let container = try ModelContainer(
                for: schema, migrationPlan: KyosakuMigrationPlan.self, configurations: configuration)
            return Opened(container: container, isSavingUnavailable: false)
        } catch {
            let nsError = error as NSError
            logger.error("Opening the store failed: \(nsError.domain, privacy: .public) \(nsError.code)")
            // Kyosaku stays usable, and the file is left alone so that nothing on disk is lost.
            return Opened(container: openInMemory(), isSavingUnavailable: true)
        }
    }

    static func openInMemory() -> ModelContainer {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            return try ModelContainer(
                for: schema, migrationPlan: KyosakuMigrationPlan.self, configurations: configuration)
        } catch {
            // Nothing here touches the disk, so a failure means SwiftData itself cannot run.
            fatalError("Could not create an in-memory store: \(error)")
        }
    }

    private static let schema = Schema(versionedSchema: KyosakuSchemaV1.self)
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Kyosaku", category: "storage")
}
