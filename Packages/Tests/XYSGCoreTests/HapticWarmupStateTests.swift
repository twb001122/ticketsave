import Testing
@testable import XYSGCore

struct HapticWarmupStateTests {
    @Test
    mutating func warmsOnlyOnce() {
        var state = HapticWarmupState()

        #expect(state.shouldWarmNow() == true)
        #expect(state.shouldWarmNow() == false)
    }
}
