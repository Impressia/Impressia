//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData

class AccountDataHandler {
    public static let shared = AccountDataHandler()
    private init() { }

    func getAccountsData(modelContext: ModelContext) -> [AccountData] {
        do {
            var fetchDescriptor = FetchDescriptor<AccountData>()
            fetchDescriptor.includePendingChanges = true

            return try modelContext.fetch(fetchDescriptor)
        } catch {
            CoreDataError.shared.handle(error, message: "Accounts cannot be retrieved (getAccountsData).")
            return []
        }
    }

    func getCurrentAccountData(modelContext: ModelContext) -> AccountData? {
        let accounts = self.getAccountsData(modelContext: modelContext)
        let defaultSettings = ApplicationSettingsHandler.shared.get(modelContext: modelContext)

        let currentAccount = accounts.first { accountData in
            accountData.id == defaultSettings.currentAccount
        }

        if let currentAccount {
            return currentAccount
        }

        return accounts.first
    }

    func getAccountData(accountId: String, modelContext: ModelContext) -> AccountData? {
        do {
            var fetchDescriptor = FetchDescriptor<AccountData>(predicate: #Predicate { accountData in
                accountData.id == accountId
            })
            fetchDescriptor.fetchLimit = 1
            fetchDescriptor.includePendingChanges = true
            
            return try modelContext.fetch(fetchDescriptor).first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching status (getAccountData).")
            return nil
        }
    }

    func remove(accountData: AccountData, modelContext: ModelContext) {
        do {
            modelContext.delete(accountData)
            try modelContext.save()
        } catch {
            CoreDataError.shared.handle(error, message: "Error during deleting account data (remove).")
        }
    }
}
