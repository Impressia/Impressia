//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import CoreHaptics
import UIKit

public class HapticService {
    public static let shared: HapticService = .init()

    public enum HapticType {
        case buttonPress
        case dataRefresh(intensity: CGFloat)
        case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
        case tabSelection
        case timeline
        case animation
    }

    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    private init() {
        selectionGenerator.prepare()
        impactGenerator.prepare()
    }

    @MainActor
    public func fireHaptic(of type: HapticType) {
        guard supportsHaptics else { return }

        switch type {
        case .buttonPress:
            impactGenerator.impactOccurred()
        case let .dataRefresh(intensity):
            impactGenerator.impactOccurred(intensity: intensity)
        case let .notification(type):
            notificationGenerator.notificationOccurred(type)
        case .tabSelection:
            selectionGenerator.selectionChanged()
        case .timeline:
            selectionGenerator.selectionChanged()
        case .animation:
            selectionGenerator.selectionChanged()
        }
    }

    public var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
}
