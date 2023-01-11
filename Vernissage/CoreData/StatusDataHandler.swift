//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation
import CoreData
import MastodonKit

class StatusDataHandler {
    public static let shared = StatusDataHandler()
    private init() { }
    
    func getStatusData(accountId: String, statusId: String) -> StatusData? {
        let context = CoreDataHandler.shared.container.viewContext
        let fetchRequest = StatusData.fetchRequest()
        
        fetchRequest.fetchLimit = 1
        let predicate1 = NSPredicate(format: "id = %@", statusId)
        let predicate2 = NSPredicate(format: "pixelfedAccount.id = %@", accountId)
        
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1,predicate2])
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            print("Error during fetching status (getStatusData)")
            return nil
        }
    }
    
    func getMaximumStatus(accountId: String, viewContext: NSManagedObjectContext? = nil) -> StatusData? {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = StatusData.fetchRequest()

        fetchRequest.fetchLimit = 1
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pixelfedAccount.id = %@", accountId)
        
        do {
            let statuses = try context.fetch(fetchRequest)
            return statuses.first
        } catch {
            print("Error during fetching maximum status (getMaximumStatus)")
            return nil
        }
    }
    
    func getMinimumStatus(accountId: String, viewContext: NSManagedObjectContext? = nil) -> StatusData? {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = StatusData.fetchRequest()

        fetchRequest.fetchLimit = 1
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "pixelfedAccount.id = %@", accountId)
        
        do {
            let statuses = try context.fetch(fetchRequest)
            return statuses.first
        } catch {
            print("Error during fetching minimum status (getMinimumtatus)")
            return nil
        }
    }
    
    func createStatusDataEntity(viewContext: NSManagedObjectContext? = nil) -> StatusData {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return StatusData(context: context)
    }
}
