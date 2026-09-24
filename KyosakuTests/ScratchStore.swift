import Foundation
import Testing

@testable import Kyosaku

/// A task store in a scratch folder, with defaults that nobody else reads.
struct ScratchStore {
    let url: URL
    let defaults: UserDefaults
    private let clock = Clock()

    func open() -> TaskStore {
        TaskStore(container: Storage.open(at: url).container, defaults: defaults, now: { clock.now() })
    }

    /// Runs `body` with a scratch store, and deletes the store and the defaults afterwards.
    static func use(_ body: (ScratchStore) throws -> Void) throws {
        try withScratchFolder { folder in
            let suiteName = "io.github.yttkhs.kyosaku.tests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suiteName))
            defer { defaults.removePersistentDomain(forName: suiteName) }
            try body(ScratchStore(url: folder.appending(path: "Kyosaku.store"), defaults: defaults))
        }
    }

    /// Moves one second forward on every reading, so that creation order never ties.
    private final class Clock {
        private var seconds = 0.0

        func now() -> Date {
            seconds += 1
            return Date(timeIntervalSinceReferenceDate: seconds)
        }
    }
}
