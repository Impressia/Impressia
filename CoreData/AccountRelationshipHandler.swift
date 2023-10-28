//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit
import SwiftData

class AccountRelationshipHandler {
    public static let shared = AccountRelationshipHandler()
    private init() { }
        
    func getAccountRelationships(for accountId: String, modelContext: ModelContext) -> [AccountRelationship] {
        do {
            var fetchDescriptor = FetchDescriptor<AccountRelationship>(
                predicate: #Predicate { $0.pixelfedAccount?.id == accountId }
            )
            fetchDescriptor.includePendingChanges = true
            
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching account relationship (isBoostedMutedForAccount).")
            return []
        }
    }
    
    /// Check if boosted statuses from given account are muted.
    func isBoostedStatusesMuted(accountId: String, status: Status, modelContext: ModelContext) -> Bool {
        if status.reblog == nil {
            return false
        }

        let accountRelationship = self.getAccountRelationship(for: accountId, relation: status.account.id, modelContext: modelContext)
        return accountRelationship?.boostedStatusesMuted ?? false
    }
    
    func isBoostedStatusesMuted(for accountId: String, relation relationAccountId: String, modelContext: ModelContext) -> Bool {
        let accountRelationship = self.getAccountRelationship(for: accountId, relation: relationAccountId, modelContext: modelContext)
        return accountRelationship?.boostedStatusesMuted ?? false
    }
    
    func setBoostedStatusesMuted(for accountId: String, relation relationAccountId: String, boostedStatusesMuted: Bool, modelContext: ModelContext) {
        var accountRelationship = self.getAccountRelationship(for: accountId, relation: relationAccountId, modelContext: modelContext)
        if accountRelationship == nil {
            guard let accountDataFromDb = AccountDataHandler.shared.getAccountData(accountId: accountId, modelContext: modelContext) else {
                return
            }
            
            let newAccountRelationship = AccountRelationship(accountId: relationAccountId, boostedStatusesMuted: false, pixelfedAccount: accountDataFromDb)
            modelContext.insert(newAccountRelationship)
            accountDataFromDb.accountRelationships.append(newAccountRelationship)

            accountRelationship = newAccountRelationship
        }
        
        accountRelationship?.boostedStatusesMuted = boostedStatusesMuted
        
        do {
            try modelContext.save()
        } catch {
            CoreDataError.shared.handle(error, message: "Error during saving boosted muted statuses.")
        }
    }
    
    private func getAccountRelationship(for accountId: String, relation relationAccountId: String, modelContext: ModelContext) -> AccountRelationship? {
        do {
            var fetchDescriptor = FetchDescriptor<AccountRelationship>(
                predicate: #Predicate { $0.accountId == relationAccountId && $0.pixelfedAccount?.id == accountId }
            )
            fetchDescriptor.fetchLimit = 1
            fetchDescriptor.includePendingChanges = true
            
            return try modelContext.fetch(fetchDescriptor).first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching account relationship (isBoostedMutedForAccount).")
            return nil
        }
    }
}
