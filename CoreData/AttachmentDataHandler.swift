//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import CoreData

class AttachmentDataHandler {
    public static let shared = AttachmentDataHandler()
    private init() { }

    func createAttachmnentDataEntity(viewContext: NSManagedObjectContext? = nil) -> AttachmentData {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return AttachmentData(context: context)
    }
    
    func getDownloadedAttachmentData(accountId: String, length: Int, viewContext: NSManagedObjectContext? = nil) -> [AttachmentData] {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        let fetchRequest = AttachmentData.fetchRequest()
        fetchRequest.fetchLimit = length

        let sortDescriptor = NSSortDescriptor(key: "statusRelation.id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate1 = NSPredicate(format: "statusRelation.pixelfedAccount.id = %@", accountId)
        let predicate2 = NSPredicate(format: "data != nil")
        fetchRequest.predicate = NSCompoundPredicate.init(type: .and, subpredicates: [predicate1, predicate2])

        do {
            return try context.fetch(fetchRequest)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching attachment data (getDownloadedAttachmentData).")
            return []
        }
    }
}
