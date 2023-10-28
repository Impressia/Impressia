//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import EnvironmentKit
import SwiftData

class ApplicationSettingsHandler {
    public static let shared = ApplicationSettingsHandler()
    private init() { }

    func get(modelContext: ModelContext) -> ApplicationSettings {
        var settingsList: [ApplicationSettings] = []

        do {
            var fetchDescriptor = FetchDescriptor<ApplicationSettings>()
            fetchDescriptor.includePendingChanges = true
            
            settingsList = try modelContext.fetch(fetchDescriptor)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching application settings.")
        }

        if let settings = settingsList.first {
            return settings
        } else {
            do {
                let settings = ApplicationSettings()
                modelContext.insert(settings)

                try modelContext.save()
                return settings
            } catch {
                CoreDataError.shared.handle(error, message: "Error during saving new application settings.")
                
                let settings = ApplicationSettings()
                return settings
            }
        }
    }

    func update(applicationState: ApplicationState, modelContext: ModelContext) {
        let defaultSettings = ApplicationSettingsHandler.shared.get(modelContext: modelContext)

        if let tintColor = TintColor(rawValue: Int(defaultSettings.tintColor)) {
            applicationState.tintColor = tintColor
        }

        if let theme = Theme(rawValue: Int(defaultSettings.theme)) {
            applicationState.theme = theme
        }

        if let avatarShape = AvatarShape(rawValue: Int(defaultSettings.avatarShape)) {
            applicationState.avatarShape = avatarShape
        }

        applicationState.activeIcon = defaultSettings.activeIcon
        applicationState.showSensitive = defaultSettings.showSensitive
        applicationState.showPhotoDescription = defaultSettings.showPhotoDescription
        applicationState.showAvatarsOnTimeline = defaultSettings.showAvatarsOnTimeline
        applicationState.showFavouritesOnTimeline = defaultSettings.showFavouritesOnTimeline
        applicationState.showAltIconOnTimeline = defaultSettings.showAltIconOnTimeline
        applicationState.warnAboutMissingAlt = defaultSettings.warnAboutMissingAlt
        applicationState.showGridOnUserProfile = defaultSettings.showGridOnUserProfile
        applicationState.showReboostedStatuses = defaultSettings.showReboostedStatuses
        applicationState.hideStatusesWithoutAlt = defaultSettings.hideStatusesWithoutAlt
        applicationState.showApplicationBadge = defaultSettings.showApplicationBadge

        if let menuPosition = MenuPosition(rawValue: Int(defaultSettings.menuPosition)) {
            applicationState.menuPosition = menuPosition
        }

        applicationState.hapticTabSelectionEnabled = defaultSettings.hapticTabSelectionEnabled
        applicationState.hapticRefreshEnabled = defaultSettings.hapticRefreshEnabled
        applicationState.hapticButtonPressEnabled = defaultSettings.hapticButtonPressEnabled
        applicationState.hapticAnimationEnabled = defaultSettings.hapticAnimationEnabled
        applicationState.hapticNotificationEnabled = defaultSettings.hapticNotificationEnabled
    }

    func set(accountId: String?, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.currentAccount = accountId
        try? modelContext.save()
    }

    func set(tintColor: TintColor, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.tintColor = Int32(tintColor.rawValue)
        try? modelContext.save()
    }

    func set(theme: Theme, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.theme = Int32(theme.rawValue)
        try? modelContext.save()
    }

    func set(avatarShape: AvatarShape, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.avatarShape = Int32(avatarShape.rawValue)
        try? modelContext.save()
    }

    func set(hapticTabSelectionEnabled: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.hapticTabSelectionEnabled = hapticTabSelectionEnabled
        try? modelContext.save()
    }

    func set(hapticRefreshEnabled: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.hapticRefreshEnabled = hapticRefreshEnabled
        try? modelContext.save()
    }

    func set(hapticAnimationEnabled: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.hapticAnimationEnabled = hapticAnimationEnabled
        try? modelContext.save()
    }

    func set(hapticNotificationEnabled: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.hapticNotificationEnabled = hapticNotificationEnabled
        try? modelContext.save()
    }

    func set(hapticButtonPressEnabled: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.hapticButtonPressEnabled = hapticButtonPressEnabled
        try? modelContext.save()
    }

    func set(showSensitive: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.showSensitive = showSensitive
        try? modelContext.save()
    }
    
    func set(showApplicationBadge: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.showApplicationBadge = showApplicationBadge
        try? modelContext.save()
    }

    func set(showPhotoDescription: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.showPhotoDescription = showPhotoDescription
        try? modelContext.save()
    }

    func set(activeIcon: String, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.activeIcon = activeIcon
        try? modelContext.save()
    }

    func set(menuPosition: MenuPosition, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.menuPosition = Int32(menuPosition.rawValue)
        try? modelContext.save()
    }

    func set(showAvatarsOnTimeline: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.showAvatarsOnTimeline = showAvatarsOnTimeline
        try? modelContext.save()
    }

    func set(showFavouritesOnTimeline: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.showFavouritesOnTimeline = showFavouritesOnTimeline
        try? modelContext.save()
    }

    func set(showAltIconOnTimeline: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.showAltIconOnTimeline = showAltIconOnTimeline
        try? modelContext.save()
    }

    func set(warnAboutMissingAlt: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.warnAboutMissingAlt = warnAboutMissingAlt
        try? modelContext.save()
    }

    func set(customNavigationMenuItem1: Int, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.customNavigationMenuItem1 = Int32(customNavigationMenuItem1)
        try? modelContext.save()
    }

    func set(customNavigationMenuItem2: Int, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.customNavigationMenuItem2 = Int32(customNavigationMenuItem2)
        try? modelContext.save()
    }

    func set(customNavigationMenuItem3: Int, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.customNavigationMenuItem3 = Int32(customNavigationMenuItem3)
        try? modelContext.save()
    }

    func set(showGridOnUserProfile: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.showGridOnUserProfile = showGridOnUserProfile
        try? modelContext.save()
    }

    func set(showReboostedStatuses: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.showReboostedStatuses = showReboostedStatuses
        try? modelContext.save()
    }

    func set(hideStatusesWithoutAlt: Bool, modelContext: ModelContext) {
        let defaultSettings = self.get(modelContext: modelContext)
        defaultSettings.hideStatusesWithoutAlt = hideStatusesWithoutAlt
        try? modelContext.save()
    }
}
