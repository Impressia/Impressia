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
    @State var showPhotoDescription = true
    
    var body: some View {
        Section("Media settings") {
            
            Toggle(isOn: $showSensitive) {
                VStack(alignment: .leading) {
                    Text("Always show NSFW")
                    Text("Force show all NFSW (sensitive) media without warnings")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
            }
            .onChange(of: showSensitive) { newValue in
                self.applicationState.showSensitive = newValue
                ApplicationSettingsHandler.shared.setShowSensitive(value: newValue)
            }
            
            Toggle(isOn: $showPhotoDescription) {
                VStack(alignment: .leading) {
                    Text("Show alternative text")
                    Text("Show alternative text if present on status details screen")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
            }
            .onChange(of: showPhotoDescription) { newValue in
                self.applicationState.showPhotoDescription = newValue
                ApplicationSettingsHandler.shared.setShowPhotoDescription(value: newValue)
            }
        }
        .onAppear {
            let defaultSettings = ApplicationSettingsHandler.shared.getDefaultSettings()
            self.showSensitive = defaultSettings.showSensitive
            self.showPhotoDescription = defaultSettings.showPhotoDescription
        }
    }
}
