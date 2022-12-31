//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation

class AccountDataHandler {
    func getAccountsData() -> [AccountData] {
        let context = CoreDataHandler.shared.container.viewContext
        let fetchRequest = AccountData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error during fetching accounts")
            return []
        }
    }

    func createAccountDataEntity() -> AccountData {
        let context = CoreDataHandler.shared.container.viewContext
        return AccountData(context: context)
    }
}
