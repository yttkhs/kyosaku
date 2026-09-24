import SwiftData

enum KyosakuMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [KyosakuSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
