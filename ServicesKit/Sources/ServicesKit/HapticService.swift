//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import CoreHaptics
import UIKit
import EnvironmentKit

public class HapticService {
    public static let shared: HapticService = .init()

    public enum HapticType {
        case buttonPress
        case dataRefresh(intensity: CGFloat)
        case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
        case tabSelection
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
            if ApplicationState.shared.hapticButtonPressEnabled {
                impactGenerator.impactOccurred()
            }
        case let .dataRefresh(intensity):
            if ApplicationState.shared.hapticRefreshEnabled {
                impactGenerator.impactOccurred(intensity: intensity)
            }
        case let .notification(type):
            if ApplicationState.shared.hapticNotificationEnabled {
                notificationGenerator.notificationOccurred(type)
            }
        case .tabSelection:
            if ApplicationState.shared.hapticTabSelectionEnabled {
                selectionGenerator.selectionChanged()
            }
        case .animation:
            if ApplicationState.shared.hapticAnimationEnabled {
                selectionGenerator.selectionChanged()
            }
        }
    }

    public var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
}
