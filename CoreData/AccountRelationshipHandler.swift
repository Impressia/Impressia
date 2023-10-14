//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData
import PixelfedKit

class AccountRelationshipHandler {
    public static let shared = AccountRelationshipHandler()
    private init() { }
    
    func createAccountRelationshipEntity(viewContext: NSManagedObjectContext? = nil) -> AccountRelationship {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return AccountRelationship(context: context)
    }
    
    /// Check if boosted statuses from given account are muted.
    func isBoostedStatusesMuted(accountId: String, status: Status, viewContext: NSManagedObjectContext? = nil) -> Bool {
        if status.reblog == nil {
            return false
        }

        let accountRelationship = self.getAccountRelationship(for: accountId, relation: status.account.id, viewContext: viewContext)
        return accountRelationship?.boostedStatusesMuted ?? false
    }
    
    func isBoostedStatusesMuted(for accountId: String, relation relationAccountId: String, viewContext: NSManagedObjectContext? = nil) -> Bool {
        let accountRelationship = self.getAccountRelationship(for: accountId, relation: relationAccountId, viewContext: viewContext)
        return accountRelationship?.boostedStatusesMuted ?? false
    }
    
    func setBoostedStatusesMuted(for accountId: String, relation relationAccountId: String, boostedStatusesMuted: Bool, viewContext: NSManagedObjectContext? = nil) {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext

        var accountRelationship = self.getAccountRelationship(for: accountId, relation: relationAccountId, viewContext: context)
        if accountRelationship == nil {
            guard let accountDataFromDb = AccountDataHandler.shared.getAccountData(accountId: accountId, viewContext: context) else {
                return
            }
            
            let newAccountRelationship = AccountRelationshipHandler.shared.createAccountRelationshipEntity(viewContext: context)
            newAccountRelationship.accountId = relationAccountId
            newAccountRelationship.pixelfedAccount = accountDataFromDb
            accountDataFromDb.addToAccountRelationships(newAccountRelationship)
            
            accountRelationship = newAccountRelationship
        }
        
        accountRelationship?.boostedStatusesMuted = boostedStatusesMuted
        CoreDataHandler.shared.save(viewContext: context)
    }
    
    private func getAccountRelationship(for accountId: String, relation relationAccountId: String, viewContext: NSManagedObjectContext? = nil) -> AccountRelationship? {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = AccountRelationship.fetchRequest()

        fetchRequest.fetchLimit = 1
        let statusAccountIddPredicate = NSPredicate(format: "accountId = %@", relationAccountId)
        let accountPredicate = NSPredicate(format: "pixelfedAccount.id = %@", accountId)
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [statusAccountIddPredicate, accountPredicate])

        do {
            return try context.fetch(fetchRequest).first
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching account relationship (isBoostedMutedForAccount).")
            return nil
        }
    }
}
