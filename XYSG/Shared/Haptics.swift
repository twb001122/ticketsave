import UIKit
import XYSGCore

enum Haptics {
    @MainActor private static let selectionGenerator = UISelectionFeedbackGenerator()
    @MainActor private static let softImpactGenerator = UIImpactFeedbackGenerator(style: .soft)
    @MainActor private static let notificationGenerator = UINotificationFeedbackGenerator()
    @MainActor private static var warmupState = HapticWarmupState()

    @MainActor
    static func prewarm() {
        guard warmupState.shouldWarmNow() else { return }
        selectionGenerator.prepare()
        softImpactGenerator.prepare()
        notificationGenerator.prepare()
    }

    @MainActor
    static func selection() {
        prewarm()
        selectionGenerator.selectionChanged()
        selectionGenerator.prepare()
    }

    @MainActor
    static func softImpact() {
        prewarm()
        softImpactGenerator.impactOccurred(intensity: 0.72)
        softImpactGenerator.prepare()
    }

    @MainActor
    static func success() {
        prewarm()
        notificationGenerator.notificationOccurred(.success)
        notificationGenerator.prepare()
    }

    @MainActor
    static func warning() {
        prewarm()
        notificationGenerator.notificationOccurred(.warning)
        notificationGenerator.prepare()
    }

    @MainActor
    static func error() {
        prewarm()
        notificationGenerator.notificationOccurred(.error)
        notificationGenerator.prepare()
    }
}
