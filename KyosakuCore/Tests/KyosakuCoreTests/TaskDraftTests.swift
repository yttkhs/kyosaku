import KyosakuCore
import Testing

struct TaskDraftTests {
    @Test func trimsBothFields() {
        let draft = TaskDraft(name: "  Write the report \n", details: "\n Section 2 first.  ")

        #expect(draft.normalized == TaskDraft(name: "Write the report", details: "Section 2 first."))
    }

    @Test func putsAPastedNameOnOneLine() {
        #expect(TaskDraft(name: "Write\nthe\r\nreport").normalized.name == "Write the report")
    }

    @Test func keepsLineBreaksInTheDetails() {
        #expect(TaskDraft(name: "Plan", details: "First\nSecond").normalized.details == "First\nSecond")
    }

    @Test func needsANameThatIsMoreThanSpaces() {
        #expect(!TaskDraft(name: " \n\t ").canSave)
        #expect(TaskDraft(name: " a ").canSave)
    }

    @Test func countsWhatAPersonSeesAsOneCharacter() {
        let coder = "\u{1F469}\u{200D}\u{1F4BB}"
        let kanji = "\u{6F22}"
        let name = String(repeating: coder, count: 99) + kanji + "\u{5B57}"

        #expect(TaskDraft(name: name).normalized.name == String(repeating: coder, count: 99) + kanji)
    }

    @Test func cutsTheDetailsAtTheirLimit() {
        let hiragana = "\u{3042}"
        let details = String(repeating: hiragana, count: TaskDraft.detailsLimit + 1)

        #expect(TaskDraft(name: "Plan", details: details).normalized.details.count == TaskDraft.detailsLimit)
    }

    @Test func clipsTypedTextOnlyWhenItIsTooLong() {
        #expect(TaskDraft.clipped("abc", limit: 3) == "abc")
        #expect(TaskDraft.clipped("abcd", limit: 3) == "abc")
        #expect(TaskDraft.clipped("e\u{301}e\u{301}", limit: 1) == "e\u{301}")
    }

    @Test func showsTheRemainingCountPastEightyPercent() {
        #expect(TaskDraft.remainingCount(of: String(repeating: "a", count: 80), limit: 100) == nil)
        #expect(TaskDraft.remainingCount(of: String(repeating: "a", count: 81), limit: 100) == 19)
        #expect(TaskDraft.remainingCount(of: String(repeating: "a", count: 100), limit: 100) == 0)
    }

    @Test func normalizesToTheSameResultTwice() {
        let once = TaskDraft(name: String(repeating: "a", count: 99) + " b", details: " x ").normalized

        #expect(once.normalized == once)
    }
}
