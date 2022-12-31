//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation

class ApplicationSettingsHandler {
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

    private func createApplicationSettingsEntity() -> ApplicationSettings {
        let context = CoreDataHandler.shared.container.viewContext
        return ApplicationSettings(context: context)
    }
}
