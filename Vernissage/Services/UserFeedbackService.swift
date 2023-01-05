//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import AVFoundation

public class UserFeedbackService {
    public static let shared = UserFeedbackService()
    private init() { }
    
    func send() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        // AudioServicesPlaySystemSound(1016)
    }
}
