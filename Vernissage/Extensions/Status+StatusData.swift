//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonSwift

extension Status {
    func createStatusData() async throws -> StatusData {
        let statusData = StatusDataHandler.shared.createStatusDataEntity(viewContext: CoreDataHandler.memory.container.viewContext)
        statusData.copyFrom(self)
                
        for attachment in self.mediaAttachments {
            let imageData = try await RemoteFileService.shared.fetchData(url: attachment.url)
            
            guard let imageData = imageData else {
                continue
            }
            
            // Save attachment in database.
            let attachmentData = AttachmentDataHandler.shared.createAttachmnentDataEntity(viewContext: CoreDataHandler.memory.container.viewContext)
            
            attachmentData.copyFrom(attachment)
            attachmentData.statusId = statusData.id
            attachmentData.data = imageData
            
            // TODO: read exif informatio
            
            attachmentData.statusRelation = statusData
            statusData.addToAttachmentRelation(attachmentData)
        }
        
        return statusData
    }
}
