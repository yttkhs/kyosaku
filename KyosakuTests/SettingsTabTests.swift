import AppKit
import Testing

@testable import Kyosaku

struct SettingsTabTests {
    @Test func listsTheFiveTabsInToolbarOrder() {
        #expect(SettingsTab.allCases == [.general, .templates, .privacy, .permissions, .stats])
    }

    @Test func namesEachTab() {
        #expect(
            SettingsTab.allCases.map(\.title) == ["General", "Templates", "Privacy", "Permissions", "Stats"])
    }

    @Test func usesSymbolsThatExist() {
        for tab in SettingsTab.allCases {
            #expect(
                NSImage(systemSymbolName: tab.symbolName, accessibilityDescription: nil) != nil,
                "\(tab): \(tab.symbolName)"
            )
        }
    }

    @Test func givesEveryTabItsOwnSymbol() {
        let symbols = SettingsTab.allCases.map(\.symbolName)
        #expect(Set(symbols).count == symbols.count)
    }
}
