//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI

struct GeneralSectionView: View {
    @EnvironmentObject var applicationState: ApplicationState
        
    private let customIconNames = ["Default", "Blue", "Violet", "Orange", "Pride", "Blue-Camera", "Violet-Camera", "Orange-Camera", "Pride-Camera"]
    private let themeNames: [(theme: Theme, name: LocalizedStringKey)] = [
        (Theme.system, "settings.title.system"),
        (Theme.light, "settings.title.light"),
        (Theme.dark, "settings.title.dark")
    ]
    
    var body: some View {
        Section("settings.title.general") {

            // Application icon.
            Picker(selection: $applicationState.activeIcon) {
                ForEach(self.customIconNames, id: \.self) { icon in
                    HStack {
                        Image("\(icon)-Preview")
                        Text(icon.replacing("-", with: " "))
                    }
                    .tag(icon)
                }
            } label: {
                Text("settings.title.applicationIcon", comment: "Application icon")
            }
            .pickerStyle(.navigationLink)
            .onChange(of: self.applicationState.activeIcon) { iconName in
                ApplicationSettingsHandler.shared.set(activeIcon: iconName)
                UIApplication.shared.setAlternateIconName(iconName)
            }
            
            // Application theme.
            Picker(selection: $applicationState.theme) {
                ForEach(self.themeNames, id: \.theme) { item in
                    Text(item.name, comment: "Theme name")
                        .tag(item.theme)
                }
            } label: {
                Text("settings.title.theme", comment: "Theme")
            }
            .onChange(of: self.applicationState.theme) { theme in
                self.applicationState.theme = theme
                ApplicationSettingsHandler.shared.set(theme: theme)
            }
        }
    }
}
