import KyosakuCore
import Testing

struct MonitoringStatusTests {
    @Test func listsTheFourMenuBarStatesInDesignOrder() {
        #expect(MonitoringStatus.allCases == [.idle, .monitoring, .nudging, .needsAttention])
    }
}
