//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import EnvironmentKit

struct MediaSettingsView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.colorScheme) var colorScheme

    @State var showSensitive = true
    @State var showPhotoDescription = true

    var body: some View {
        Section("settings.title.mediaSettings") {

            Toggle(isOn: $showSensitive) {
                VStack(alignment: .leading) {
                    Text("settings.title.alwaysShowSensitiveTitle", comment: "Always show NSFW")
                    Text("settings.title.alwaysShowSensitiveDescription", comment: "Force show all NFSW (sensitive) media without warnings")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
            }
            .onChange(of: showSensitive) { newValue in
                self.applicationState.showSensitive = newValue
                ApplicationSettingsHandler.shared.set(showSensitive: newValue)
            }

            Toggle(isOn: $showPhotoDescription) {
                VStack(alignment: .leading) {
                    Text("settings.title.alwaysShowAltTitle", comment: "Show alternative text")
                    Text("settings.title.alwaysShowAltDescription", comment: "Show alternative text if present on status details screen")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
            }
            .onChange(of: showPhotoDescription) { newValue in
                self.applicationState.showPhotoDescription = newValue
                ApplicationSettingsHandler.shared.set(showPhotoDescription: newValue)
            }
        }
        .onAppear {
            let defaultSettings = ApplicationSettingsHandler.shared.get()
            self.showSensitive = defaultSettings.showSensitive
            self.showPhotoDescription = defaultSettings.showPhotoDescription
        }
    }
}
