//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData

class AccountDataHandler {
    public static let shared = AccountDataHandler()
    private init() { }

    func getAccountsData(viewContext: NSManagedObjectContext? = nil) -> [AccountData] {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = AccountData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            CoreDataError.shared.handle(error, message: "Accounts cannot be retrieved (getAccountsData).")
            return []
        }
    }

    func getCurrentAccountData(viewContext: NSManagedObjectContext? = nil) -> AccountData? {
        let accounts = self.getAccountsData(viewContext: viewContext)
        let defaultSettings = ApplicationSettingsHandler.shared.get()

        let currentAccount = accounts.first { accountData in
            accountData.id == defaultSettings.currentAccount
        }

        if let currentAccount {
            return currentAccount
        }

        return accounts.first
    }

    func getAccountData(accountId: String, viewContext: NSManagedObjectContext? = nil) -> AccountData? {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = AccountData.fetchRequest()

        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id = %@", accountId)

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching status (getAccountData).")
            return nil
        }
    }

    func remove(accountData: AccountData) {
        let context = CoreDataHandler.shared.container.viewContext
        context.delete(accountData)

        do {
            try context.save()
        } catch {
            CoreDataError.shared.handle(error, message: "Error during deleting account data (remove).")
        }
    }

    func createAccountDataEntity(viewContext: NSManagedObjectContext? = nil) -> AccountData {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return AccountData(context: context)
    }
}
