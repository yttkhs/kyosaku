import SwiftData

// Until the first release this version may still change; after it, every change needs a new version.
enum KyosakuSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] { [WorkTaskRecord.self] }
}

typealias WorkTaskRecord = KyosakuSchemaV1.WorkTaskRecord
