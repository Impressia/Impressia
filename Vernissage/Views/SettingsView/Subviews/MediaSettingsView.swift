//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import EnvironmentKit

struct MediaSettingsView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        @Bindable var applicationState = applicationState

        Section("settings.title.mediaSettings") {

            Toggle(isOn: $applicationState.showSensitive) {
                VStack(alignment: .leading) {
                    Text("settings.title.alwaysShowSensitiveTitle", comment: "Always show NSFW")
                    Text("settings.title.alwaysShowSensitiveDescription", comment: "Force show all NFSW (sensitive) media without warnings")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.showSensitive) { oldValue, newValue in
                ApplicationSettingsHandler.shared.set(showSensitive: newValue)
            }

            Toggle(isOn: $applicationState.showPhotoDescription) {
                VStack(alignment: .leading) {
                    Text("settings.title.alwaysShowAltTitle", comment: "Show alternative text")
                    Text("settings.title.alwaysShowAltDescription", comment: "Show alternative text if present on status details screen")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.showPhotoDescription) { oldValue, newValue in
                ApplicationSettingsHandler.shared.set(showPhotoDescription: newValue)
            }

            Toggle(isOn: $applicationState.showAvatarsOnTimeline) {
                VStack(alignment: .leading) {
                    Text("settings.title.showAvatars", comment: "Show avatars")
                    Text("settings.title.showAvatarsOnTimeline", comment: "Show avatars on timeline")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.showAvatarsOnTimeline) { oldValue, newValue in
                ApplicationSettingsHandler.shared.set(showAvatarsOnTimeline: newValue)
            }

            Toggle(isOn: $applicationState.showFavouritesOnTimeline) {
                VStack(alignment: .leading) {
                    Text("settings.title.showFavourite", comment: "Show favourites")
                    Text("settings.title.showFavouriteOnTimeline", comment: "Show favourites on timeline")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.showFavouritesOnTimeline) { oldValue, newValue in
                ApplicationSettingsHandler.shared.set(showFavouritesOnTimeline: newValue)
            }

            Toggle(isOn: $applicationState.showAltIconOnTimeline) {
                VStack(alignment: .leading) {
                    Text("settings.title.showAltText", comment: "Show ALT icon")
                    Text("settings.title.showAltTextOnTimeline", comment: "ALT icon will be displayed on timelines")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.showAltIconOnTimeline) { oldValue, newValue in
                ApplicationSettingsHandler.shared.set(showAltIconOnTimeline: newValue)
            }

            Toggle(isOn: $applicationState.warnAboutMissingAlt) {
                VStack(alignment: .leading) {
                    Text("settings.title.warnAboutMissingAltTitle", comment: "Warn of missing ALT text")
                    Text("settings.title.warnAboutMissingAltDescription", comment: "A warning about missing ALT texts will be displayed before publishing new post.")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.warnAboutMissingAlt) { oldValue, newValue in
                ApplicationSettingsHandler.shared.set(warnAboutMissingAlt: newValue)
            }
            
            Toggle(isOn: $applicationState.showReboostedStatuses) {
                VStack(alignment: .leading) {
                    Text("settings.title.enableReboostOnTimeline", comment: "Show boosted statuses")
                    Text("settings.title.enableReboostOnTimelineDescription", comment: "Boosted statuses will be visible on your home timeline.")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.showReboostedStatuses) { oldValue, newValue in
                ApplicationSettingsHandler.shared.set(showReboostedStatuses: newValue)
            }
            
            Toggle(isOn: $applicationState.hideStatusesWithoutAlt) {
                VStack(alignment: .leading) {
                    Text("settings.title.hideStatusesWithoutAlt", comment: "Hide statuses without ALT")
                    Text("settings.title.hideStatusesWithoutAltDescription", comment: "Statuses without ALT text will not be visible on your home timeline.")
                        .font(.footnote)
                        .foregroundColor(.customGrayColor)
                }
            }
            .onChange(of: self.applicationState.hideStatusesWithoutAlt) { oldValue, newValue in
                ApplicationSettingsHandler.shared.set(hideStatusesWithoutAlt: newValue)
            }
        }
    }
}
