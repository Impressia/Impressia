//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData
import EnvironmentKit

class ApplicationSettingsHandler {
    public static let shared = ApplicationSettingsHandler()
    private init() { }

    func get(viewContext: NSManagedObjectContext? = nil) -> ApplicationSettings {
        var settingsList: [ApplicationSettings] = []

        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = ApplicationSettings.fetchRequest()
        do {
            settingsList = try context.fetch(fetchRequest)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching application settings.")
        }

        if let settings = settingsList.first {
            return settings
        } else {
            let settings = self.createApplicationSettingsEntity(viewContext: context)
            settings.avatarShape = Int32(AvatarShape.circle.rawValue)
            settings.theme = Int32(Theme.system.rawValue)
            settings.tintColor = Int32(TintColor.accentColor2.rawValue)
            CoreDataHandler.shared.save(viewContext: context)

            return settings
        }
    }

    func update(applicationState: ApplicationState) {
        let defaultSettings = ApplicationSettingsHandler.shared.get()

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

        if let menuPosition = MenuPosition(rawValue: Int(defaultSettings.menuPosition)) {
            applicationState.menuPosition = menuPosition
        }

        applicationState.hapticTabSelectionEnabled = defaultSettings.hapticTabSelectionEnabled
        applicationState.hapticRefreshEnabled = defaultSettings.hapticRefreshEnabled
        applicationState.hapticButtonPressEnabled = defaultSettings.hapticButtonPressEnabled
        applicationState.hapticAnimationEnabled = defaultSettings.hapticAnimationEnabled
        applicationState.hapticNotificationEnabled = defaultSettings.hapticNotificationEnabled
    }

    func set(accountId: String?) {
        let defaultSettings = self.get()
        defaultSettings.currentAccount = accountId
        CoreDataHandler.shared.save()
    }

    func set(tintColor: TintColor) {
        let defaultSettings = self.get()
        defaultSettings.tintColor = Int32(tintColor.rawValue)
        CoreDataHandler.shared.save()
    }

    func set(theme: Theme) {
        let defaultSettings = self.get()
        defaultSettings.theme = Int32(theme.rawValue)
        CoreDataHandler.shared.save()
    }

    func set(avatarShape: AvatarShape) {
        let defaultSettings = self.get()
        defaultSettings.avatarShape = Int32(avatarShape.rawValue)
        CoreDataHandler.shared.save()
    }

    func set(hapticTabSelectionEnabled: Bool) {
        let defaultSettings = self.get()
        defaultSettings.hapticTabSelectionEnabled = hapticTabSelectionEnabled
        CoreDataHandler.shared.save()
    }

    func set(hapticRefreshEnabled: Bool) {
        let defaultSettings = self.get()
        defaultSettings.hapticRefreshEnabled = hapticRefreshEnabled
        CoreDataHandler.shared.save()
    }

    func set(hapticAnimationEnabled: Bool) {
        let defaultSettings = self.get()
        defaultSettings.hapticAnimationEnabled = hapticAnimationEnabled
        CoreDataHandler.shared.save()
    }

    func set(hapticNotificationEnabled: Bool) {
        let defaultSettings = self.get()
        defaultSettings.hapticNotificationEnabled = hapticNotificationEnabled
        CoreDataHandler.shared.save()
    }

    func set(hapticButtonPressEnabled: Bool) {
        let defaultSettings = self.get()
        defaultSettings.hapticButtonPressEnabled = hapticButtonPressEnabled
        CoreDataHandler.shared.save()
    }

    func set(showSensitive: Bool) {
        let defaultSettings = self.get()
        defaultSettings.showSensitive = showSensitive
        CoreDataHandler.shared.save()
    }

    func set(showPhotoDescription: Bool) {
        let defaultSettings = self.get()
        defaultSettings.showPhotoDescription = showPhotoDescription
        CoreDataHandler.shared.save()
    }

    func set(activeIcon: String) {
        let defaultSettings = self.get()
        defaultSettings.activeIcon = activeIcon
        CoreDataHandler.shared.save()
    }

    func set(menuPosition: MenuPosition) {
        let defaultSettings = self.get()
        defaultSettings.menuPosition = Int32(menuPosition.rawValue)
        CoreDataHandler.shared.save()
    }

    func set(showAvatarsOnTimeline: Bool) {
        let defaultSettings = self.get()
        defaultSettings.showAvatarsOnTimeline = showAvatarsOnTimeline
        CoreDataHandler.shared.save()
    }

    private func createApplicationSettingsEntity(viewContext: NSManagedObjectContext? = nil) -> ApplicationSettings {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return ApplicationSettings(context: context)
    }
}
