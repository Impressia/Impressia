//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import CoreHaptics

public final class HapticService: ObservableObject {
    public static let shared = HapticService()
    
    private let hapticEngine: CHHapticEngine?
    private var needsToRestart = false

    /// Fires a transient haptic event with the given intensity and sharpness (0-1).
    public func touch(intensity: Float = 0.75, sharpness: Float = 0.5) {
        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
                ],
                relativeTime: 0)
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            
            if needsToRestart {
                try? start()
            }
            
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }

    private init() {
        hapticEngine = try? CHHapticEngine()
        hapticEngine?.resetHandler = resetHandler
        hapticEngine?.stoppedHandler = restartHandler
        hapticEngine?.playsHapticsOnly = true
        try? start()
    }

    /// Stops the internal CHHapticEngine. Should be called when your app enters the background.
    public func stop(completionHandler: CHHapticEngine.CompletionHandler? = nil) {
        hapticEngine?.stop(completionHandler: completionHandler)
    }

    /// Starts the internal CHHapticEngine. Should be called when your app enters the foreground.
    public func start() throws {
        try hapticEngine?.start()
        needsToRestart = false
    }

    private func resetHandler() {
        do {
            try start()
        } catch {
            needsToRestart = true
        }
    }

    private func restartHandler(_ reasonForStopping: CHHapticEngine.StoppedReason? = nil) {
        resetHandler()
    }

}
