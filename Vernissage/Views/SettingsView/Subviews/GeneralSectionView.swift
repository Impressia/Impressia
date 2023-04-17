//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import EnvironmentKit

struct GeneralSectionView: View {
    @EnvironmentObject var applicationState: ApplicationState

    private let customIconNames = ["Default",
                                   "Blue",
                                   "Violet",
                                   "Orange",
                                   "Pride",
                                   "Yellow",
                                   "Gradient",
                                   "Blue-Camera",
                                   "Violet-Camera",
                                   "Orange-Camera",
                                   "Pride-Camera",
                                   "Yellow-Camera",
                                   "Gradient-Camera"]

    private let themeNames: [(theme: Theme, name: LocalizedStringKey)] = [
        (Theme.system, "settings.title.system"),
        (Theme.light, "settings.title.light"),
        (Theme.dark, "settings.title.dark")
    ]

    private let menuPositions: [(menuPosition: MenuPosition, name: LocalizedStringKey)] = [
        (MenuPosition.top, "settings.title.topMenu"),
        (MenuPosition.bottomRight, "settings.title.bottomRightMenu"),
        (MenuPosition.bottomLeft, "settings.title.bottomLeftMenu")
    ]

    var body: some View {
        Section("settings.title.general") {

            // Application icon.
            Picker(selection: $applicationState.activeIcon) {
                ForEach(self.customIconNames, id: \.self) { icon in
                    HStack {
                        Image("\(icon)-Preview")
                        Text(icon.replacing("-", with: " "))
                            .font(.subheadline)
                    }
                    .tag(icon)
                }
            } label: {
                Text("settings.title.applicationIcon", comment: "Application icon")
            }
            .pickerStyle(.navigationLink)
            .onChange(of: self.applicationState.activeIcon) { iconName in
                ApplicationSettingsHandler.shared.set(activeIcon: iconName)
                UIApplication.shared.setAlternateIconName(iconName == "Default" ? nil : iconName)
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
                ApplicationSettingsHandler.shared.set(theme: theme)
            }

            // Menu position.
            Picker(selection: $applicationState.menuPosition) {
                ForEach(self.menuPositions, id: \.menuPosition) { item in
                    Text(item.name, comment: "Menu positions")
                        .tag(item.menuPosition)
                }
            } label: {
                Text("settings.title.menuPosition", comment: "Menu position")
            }
            .onChange(of: self.applicationState.menuPosition) { menuPosition in
                ApplicationSettingsHandler.shared.set(menuPosition: menuPosition)
            }
        }
    }
}
