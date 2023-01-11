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
    
    func createAttachmnentDataEntity(viewContext: NSManagedObjectContext? = nil) -> AttachmentData {
        let context = viewContext ?? CoreDataHandler.shared.container.viewContext
        return AttachmentData(context: context)
    }
}
