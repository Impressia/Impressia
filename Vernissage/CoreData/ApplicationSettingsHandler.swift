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
            print("Error during fetching application settings")
        }

        if let settings = settingsList.first {
            return settings
        } else {
            let settings = self.createApplicationSettingsEntity()
            CoreDataHandler.shared.save()

            return settings
        }
    }
    
    func setAccountAsDefault(accountData: AccountData) {
        let defaultSettings = self.getDefaultSettings()
        defaultSettings.currentAccount = accountData.id
        CoreDataHandler.shared.save()
    }

    private func createApplicationSettingsEntity() -> ApplicationSettings {
        let context = CoreDataHandler.shared.container.viewContext
        return ApplicationSettings(context: context)
    }
}
