//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData

class AttachmentDataHandler {
    public static let shared = AttachmentDataHandler()
    private init() { }
    
    func getDownloadedAttachmentData(accountId: String, length: Int, modelContext: ModelContext) -> [AttachmentData] {
        do {
            var fetchDescriptor = FetchDescriptor<AttachmentData>(predicate: #Predicate { attachmentData in
                attachmentData.statusRelation?.pixelfedAccount?.id == accountId && attachmentData.data != nil
            }, sortBy: [SortDescriptor(\.statusRelation?.id, order: .forward)])
            fetchDescriptor.fetchLimit = length
            fetchDescriptor.includePendingChanges = true
            
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            CoreDataError.shared.handle(error, message: "Error during fetching attachment data (getDownloadedAttachmentData).")
            return []
        }
    }
}
