import AppKit
import Testing

@testable import Kyosaku

struct ActivationPolicyTests {
    @Test func showsTheDockIconWhenTheFirstWindowOpens() {
        var applied: [NSApplication.ActivationPolicy] = []
        let policy = ActivationPolicy { applied.append($0) }

        policy.windowDidOpen(NSWindow())

        #expect(applied == [.regular])
    }

    @Test func keepsTheDockIconUntilTheLastWindowCloses() {
        var applied: [NSApplication.ActivationPolicy] = []
        let policy = ActivationPolicy { applied.append($0) }
        let first = NSWindow()
        let second = NSWindow()

        policy.windowDidOpen(first)
        policy.windowDidOpen(second)
        policy.windowDidClose(first)
        #expect(applied == [.regular])

        policy.windowDidClose(second)
        #expect(applied == [.regular, .accessory])
    }

    @Test func countsAWindowOpenedTwiceOnce() {
        var applied: [NSApplication.ActivationPolicy] = []
        let policy = ActivationPolicy { applied.append($0) }
        let window = NSWindow()

        policy.windowDidOpen(window)
        policy.windowDidOpen(window)
        policy.windowDidClose(window)

        #expect(applied == [.regular, .accessory])
    }

    @Test func ignoresAWindowItNeverSawOpen() {
        var applied: [NSApplication.ActivationPolicy] = []
        let policy = ActivationPolicy { applied.append($0) }

        policy.windowDidClose(NSWindow())

        #expect(applied.isEmpty)
    }
}
