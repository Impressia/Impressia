//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct MediaSettingsView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.colorScheme) var colorScheme
    
    @State var showSensitive = true
    
    var body: some View {
        Section("Media settings") {
            
            Toggle("Always show NSFW (sensitive)", isOn: $showSensitive)
                .onChange(of: showSensitive) { newValue in
                    self.applicationState.showSensitive = newValue
                    ApplicationSettingsHandler.shared.setShowSensitive(value: newValue)
                }
        }
        .onAppear {
            let defaultSettings = ApplicationSettingsHandler.shared.getDefaultSettings()
            self.showSensitive = defaultSettings.showSensitive
        }
    }
}
