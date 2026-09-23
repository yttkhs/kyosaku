import AppKit
import KyosakuCore
import Testing

@testable import Kyosaku

struct MenuBarIconTests {
    @Test func usesSymbolsThatExist() {
        for status in MonitoringStatus.allCases {
            let name = MenuBarIcon.symbolName(for: status)
            #expect(
                NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil, "\(status): \(name)")
        }
    }

    @Test func givesEveryStatusItsOwnSymbol() {
        let names = MonitoringStatus.allCases.map(MenuBarIcon.symbolName(for:))
        #expect(Set(names).count == names.count)
    }
}
