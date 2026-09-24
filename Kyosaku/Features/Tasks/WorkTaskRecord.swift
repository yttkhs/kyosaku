import Foundation
import KyosakuCore
import SwiftData

extension KyosakuSchemaV1 {
    @Model
    final class WorkTaskRecord {
        @Attribute(.unique) var id: UUID
        var name: String
        var details: String
        var createdAt: Date
        var completedAt: Date?
        var revision: Int

        init(_ task: WorkTask) {
            id = task.id
            name = task.name
            details = task.details
            createdAt = task.createdAt
            completedAt = task.completedAt
            revision = task.revision
        }

        var task: WorkTask {
            WorkTask(
                id: id,
                name: name,
                details: details,
                createdAt: createdAt,
                completedAt: completedAt,
                revision: revision
            )
        }

        func update(from task: WorkTask) {
            name = task.name
            details = task.details
            completedAt = task.completedAt
            revision = task.revision
        }
    }
}
