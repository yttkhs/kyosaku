import Foundation

/// Runs `body` with a folder of its own, and deletes the folder afterwards.
func withScratchFolder(_ body: (URL) throws -> Void) throws {
    let folder = FileManager.default.temporaryDirectory.appending(
        path: "KyosakuTests-\(UUID().uuidString)", directoryHint: .isDirectory)
    defer { try? FileManager.default.removeItem(at: folder) }
    try body(folder)
}
