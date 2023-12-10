//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData
import PixelfedKit
import EnvironmentKit

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
            var fetchDescriptor = FetchDescriptor<AccountData>(
                predicate: #Predicate { $0.id == accountId}
            )
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
    
    func update(lastSeenStatusId: String?, lastLoadedStatusId: String?, statuses: Linkable<[Status]>? = nil, applicationState: ApplicationState, modelContext: ModelContext) throws {
        guard let accountId = applicationState.account?.id else {
            return
        }
        
        guard let accountDataFromDb = self.getAccountData(accountId: accountId, modelContext: modelContext) else {
            return
        }
        
        if (accountDataFromDb.lastSeenStatusId ?? "0") < (lastSeenStatusId ?? "0") {
            accountDataFromDb.lastSeenStatusId = lastSeenStatusId
            applicationState.lastSeenStatusId = lastSeenStatusId
        }

        if (accountDataFromDb.lastLoadedStatusId ?? "0") < (lastLoadedStatusId ?? "0") {
            accountDataFromDb.lastLoadedStatusId = lastLoadedStatusId
        }
        
        if let statuses, let statusesJsonData = try? JSONEncoder().encode(statuses) {
            accountDataFromDb.timelineCache = String(data: statusesJsonData, encoding: .utf8)
        }
        
        try modelContext.save()
    }
    
    func update(lastSeenNotificationId: String?, applicationState: ApplicationState, modelContext: ModelContext) throws {
        guard let accountId = applicationState.account?.id else {
            return
        }

        guard let accountDataFromDb = self.getAccountData(accountId: accountId, modelContext: modelContext) else {
            return
        }
        
        if (accountDataFromDb.lastSeenNotificationId ?? "0") < (lastSeenNotificationId ?? "0") {
            accountDataFromDb.lastSeenNotificationId = lastSeenNotificationId
            applicationState.lastSeenNotificationId = lastSeenNotificationId
        }
        
        try modelContext.save()
    }
}
