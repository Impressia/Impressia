//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation
import CoreData

class AttachmentDataHandler {
    public static let shared = AttachmentDataHandler()
    private init() { }

    func getAttachmentsData() -> [AttachmentData] {
        let context = CoreDataHandler.shared.container.viewContext
        let fetchRequest = AttachmentData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error during fetching attachmens (getAttachmentsData)")
            return []
        }
    }
    
    func createAttachmnentDataEntity(viewContext: NSManagedObjectContext? = nil) -> AttachmentData {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return AttachmentData(context: context)
    }
}
