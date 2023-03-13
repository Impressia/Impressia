//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct HapticsSectionView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.colorScheme) var colorScheme
    
    @State var hapticTabSelectionEnabled = true
    @State var hapticButtonPressEnabled = true
    @State var hapticRefreshEnabled = true
    @State var hapticAnimationEnabled = true
    @State var hapticNotificationEnabled = true
    
    var body: some View {
        Section("settings.title.haptics") {
            
            Toggle("settings.title.hapticsTabSelection", isOn: $hapticTabSelectionEnabled)
                .onChange(of: hapticTabSelectionEnabled) { newValue in
                    self.applicationState.hapticTabSelectionEnabled = newValue
                    ApplicationSettingsHandler.shared.setHapticTabSelectionEnabled(value: newValue)
                }
            
            Toggle("settings.title.hapticsButtonPress", isOn: $hapticButtonPressEnabled)
                .onChange(of: hapticButtonPressEnabled) { newValue in
                    self.applicationState.hapticButtonPressEnabled = newValue
                    ApplicationSettingsHandler.shared.setHapticButtonPressEnabled(value: newValue)
                }
            
            Toggle("settings.title.hapticsListRefresh", isOn: $hapticRefreshEnabled)
                .onChange(of: hapticRefreshEnabled) { newValue in
                    self.applicationState.hapticRefreshEnabled = newValue
                    ApplicationSettingsHandler.shared.setHapticRefreshEnabled(value: newValue)
                }
            
            Toggle("settings.title.hapticsAnimationFinished", isOn: $hapticAnimationEnabled)
                .onChange(of: hapticAnimationEnabled) { newValue in
                    self.applicationState.hapticAnimationEnabled = newValue
                    ApplicationSettingsHandler.shared.setHapticAnimationEnabled(value: newValue)
                }
            
//            Toggle("Notification", isOn: $hapticNotificationEnabled)
//                .onChange(of: hapticNotificationEnabled) { newValue in
//                    self.applicationState.hapticNotificationEnabled = newValue
//                    ApplicationSettingsHandler.shared.setHapticNotificationEnabled(value: newValue)
//                }
        }
        .onAppear {
            let defaultSettings = ApplicationSettingsHandler.shared.getDefaultSettings()
            self.hapticTabSelectionEnabled = defaultSettings.hapticTabSelectionEnabled
            self.hapticButtonPressEnabled = defaultSettings.hapticButtonPressEnabled
            self.hapticRefreshEnabled = defaultSettings.hapticRefreshEnabled
            self.hapticAnimationEnabled = defaultSettings.hapticAnimationEnabled
            self.hapticNotificationEnabled = defaultSettings.hapticNotificationEnabled
        }
    }
}
