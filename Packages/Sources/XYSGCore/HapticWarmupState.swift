public struct HapticWarmupState: Sendable {
    private var hasWarmed = false

    public init() {}

    public mutating func shouldWarmNow() -> Bool {
        guard hasWarmed == false else { return false }
        hasWarmed = true
        return true
    }
}
