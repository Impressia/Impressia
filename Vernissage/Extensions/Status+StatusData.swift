//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

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
            
            // Read exif information.
            if let exifProperties = imageData.getExifData() {
                if let make = exifProperties.getExifValue("Make"), let model = exifProperties.getExifValue("Model") {
                    attachmentData.exifCamera = "\(make) \(model)"
                }
                
                // "Lens" or "Lens Model"
                if let lens = exifProperties.getExifValue("Lens") {
                    attachmentData.exifLens = lens
                }
                
                if let createData = exifProperties.getExifValue("CreateDate") {
                    attachmentData.exifCreatedDate = createData
                }
                
                if let focalLenIn35mmFilm = exifProperties.getExifValue("FocalLenIn35mmFilm"),
                   let fNumber = exifProperties.getExifValue("FNumber")?.calculateExifNumber(),
                   let exposureTime = exifProperties.getExifValue("ExposureTime"),
                   let photographicSensitivity = exifProperties.getExifValue("PhotographicSensitivity") {
                    attachmentData.exifExposure = "\(focalLenIn35mmFilm)mm, f/\(fNumber), \(exposureTime)s, ISO \(photographicSensitivity)"
                }
            }
            
            attachmentData.statusRelation = statusData
            statusData.addToAttachmentRelation(attachmentData)
        }
        
        return statusData
    }
}
