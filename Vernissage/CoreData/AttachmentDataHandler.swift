//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation

class AttachmentDataHandler {
    func getAttachmentsData() -> [AttachmentData] {
        let context = CoreDataHandler.shared.container.viewContext
        let fetchRequest = AttachmentData.fetchRequest()
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error during fetching accounts")
            return []
        }
    }
    
    func createAttachmnentDataEntity() -> AttachmentData {
        let context = CoreDataHandler.shared.container.viewContext
        return AttachmentData(context: context)
    }
}
