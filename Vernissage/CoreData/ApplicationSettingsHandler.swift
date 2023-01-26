//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

class ApplicationSettingsHandler {
    public static let shared = ApplicationSettingsHandler()
    private init() { }
    
    func getDefaultSettings() -> ApplicationSettings {
        var settingsList: [ApplicationSettings] = []

        let context = CoreDataHandler.shared.container.viewContext
        let fetchRequest = ApplicationSettings.fetchRequest()
        do {
            settingsList = try context.fetch(fetchRequest)
        } catch {
            ErrorService.shared.handle(error, message: "Error during fetching application settings.")
        }

        if let settings = settingsList.first {
            return settings
        } else {
            let settings = self.createApplicationSettingsEntity()
            settings.avatarShape = Int32(AvatarShape.circle.rawValue)
            settings.theme = Int32(Theme.system.rawValue)
            settings.tintColor = Int32(TintColor.accentColor2.rawValue)
            CoreDataHandler.shared.save()

            return settings
        }
    }
    
    func setAccountAsDefault(accountData: AccountData) {
        let defaultSettings = self.getDefaultSettings()
        defaultSettings.currentAccount = accountData.id
        CoreDataHandler.shared.save()
    }

    func setDefaultTintColor(tintColor: TintColor) {
        let defaultSettings = self.getDefaultSettings()
        defaultSettings.tintColor = Int32(tintColor.rawValue)
        CoreDataHandler.shared.save()
    }

    func setDefaultTheme(theme: Theme) {
        let defaultSettings = self.getDefaultSettings()
        defaultSettings.theme = Int32(theme.rawValue)
        CoreDataHandler.shared.save()
    }
    
    func setDefaultAvatarShape(avatarShape: AvatarShape) {
        let defaultSettings = self.getDefaultSettings()
        defaultSettings.avatarShape = Int32(avatarShape.rawValue)
        CoreDataHandler.shared.save()
    }
    
    private func createApplicationSettingsEntity() -> ApplicationSettings {
        let context = CoreDataHandler.shared.container.viewContext
        return ApplicationSettings(context: context)
    }
}
