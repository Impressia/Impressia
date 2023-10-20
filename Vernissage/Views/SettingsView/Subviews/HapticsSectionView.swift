//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import EnvironmentKit

struct HapticsSectionView: View {
    @Environment(ApplicationState.self) var applicationState
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    @State var hapticTabSelectionEnabled = true
    @State var hapticButtonPressEnabled = true
    @State var hapticRefreshEnabled = true
    @State var hapticAnimationEnabled = true
    @State var hapticNotificationEnabled = true

    var body: some View {
        Section("settings.title.haptics") {

            Toggle("settings.title.hapticsTabSelection", isOn: $hapticTabSelectionEnabled)
                .onChange(of: hapticTabSelectionEnabled) { oldValue, newValue in
                    self.applicationState.hapticTabSelectionEnabled = newValue
                    ApplicationSettingsHandler.shared.set(hapticTabSelectionEnabled: newValue, modelContext: modelContext)
                }

            Toggle("settings.title.hapticsButtonPress", isOn: $hapticButtonPressEnabled)
                .onChange(of: hapticButtonPressEnabled) { oldValue, newValue in
                    self.applicationState.hapticButtonPressEnabled = newValue
                    ApplicationSettingsHandler.shared.set(hapticButtonPressEnabled: newValue, modelContext: modelContext)
                }

            Toggle("settings.title.hapticsListRefresh", isOn: $hapticRefreshEnabled)
                .onChange(of: hapticRefreshEnabled) { oldValue, newValue in
                    self.applicationState.hapticRefreshEnabled = newValue
                    ApplicationSettingsHandler.shared.set(hapticRefreshEnabled: newValue, modelContext: modelContext)
                }

            Toggle("settings.title.hapticsAnimationFinished", isOn: $hapticAnimationEnabled)
                .onChange(of: hapticAnimationEnabled) { oldValue, newValue in
                    self.applicationState.hapticAnimationEnabled = newValue
                    ApplicationSettingsHandler.shared.set(hapticAnimationEnabled: newValue, modelContext: modelContext)
                }

//            Toggle("Notification", isOn: $hapticNotificationEnabled)
//                .onChange(of: hapticNotificationEnabled) { newValue in
//                    self.applicationState.hapticNotificationEnabled = newValue
//                    ApplicationSettingsHandler.shared.set(hapticNotificationEnabled: newValue)
//                }
        }
        .onAppear {
            let defaultSettings = ApplicationSettingsHandler.shared.get(modelContext: modelContext)
            self.hapticTabSelectionEnabled = defaultSettings.hapticTabSelectionEnabled
            self.hapticButtonPressEnabled = defaultSettings.hapticButtonPressEnabled
            self.hapticRefreshEnabled = defaultSettings.hapticRefreshEnabled
            self.hapticAnimationEnabled = defaultSettings.hapticAnimationEnabled
            self.hapticNotificationEnabled = defaultSettings.hapticNotificationEnabled
        }
    }
}
