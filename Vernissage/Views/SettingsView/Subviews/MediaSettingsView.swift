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

    var body: some View {
        Section("settings.title.mediaSettings") {

            Toggle(isOn: $applicationState.showSensitive) {
                VStack(alignment: .leading) {
                    Text("settings.title.alwaysShowSensitiveTitle", comment: "Always show NSFW")
                    Text("settings.title.alwaysShowSensitiveDescription", comment: "Force show all NFSW (sensitive) media without warnings")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
            }
            .onChange(of: self.applicationState.showSensitive) { newValue in
                ApplicationSettingsHandler.shared.set(showSensitive: newValue)
            }

            Toggle(isOn: $applicationState.showPhotoDescription) {
                VStack(alignment: .leading) {
                    Text("settings.title.alwaysShowAltTitle", comment: "Show alternative text")
                    Text("settings.title.alwaysShowAltDescription", comment: "Show alternative text if present on status details screen")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
            }
            .onChange(of: self.applicationState.showPhotoDescription) { newValue in
                ApplicationSettingsHandler.shared.set(showPhotoDescription: newValue)
            }

            Toggle(isOn: $applicationState.showAvatarsOnTimeline) {
                VStack(alignment: .leading) {
                    Text("settings.title.showAvatars", comment: "Show avatars")
                    Text("settings.title.showAvatarsOnTimeline", comment: "Show avatars on timeline")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
            }
            .onChange(of: self.applicationState.showAvatarsOnTimeline) { newValue in
                ApplicationSettingsHandler.shared.set(showAvatarsOnTimeline: newValue)
            }

            Toggle(isOn: $applicationState.showFavouritesOnTimeline) {
                VStack(alignment: .leading) {
                    Text("settings.title.showFavourite", comment: "Show favourites")
                    Text("settings.title.showFavouriteOnTimeline", comment: "Show favourites on timeline")
                        .font(.footnote)
                        .foregroundColor(.lightGrayColor)
                }
            }
            .onChange(of: self.applicationState.showFavouritesOnTimeline) { newValue in
                ApplicationSettingsHandler.shared.set(showFavouritesOnTimeline: newValue)
            }
        }
    }
}
