//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import CoreData
import MastodonKit

public class TimelineService {
    public static let shared = TimelineService()
    private init() { }
    
    public func onBottomOfList(for accountData: AccountData) async throws {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get maximimum downloaded stauts id.
        let oldestStatus = StatusDataHandler.shared.getMinimumtatus(viewContext: backgroundContext)
        
        guard let oldestStatus = oldestStatus else {
            return
        }
        
        try await self.loadData(for: accountData, on: backgroundContext, maxId: oldestStatus.id)
    }

    public func onTopOfList(for accountData: AccountData) async throws {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get maximimum downloaded stauts id.
        let newestStatus = StatusDataHandler.shared.getMaximumStatus(viewContext: backgroundContext)
                
        try await self.loadData(for: accountData, on: backgroundContext, minId: newestStatus?.id)
    }
    
    public func getStatus(withId statusId: String, and accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }

        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.read(statusId: statusId)
    }
    
    public func getComments(for statusId: String, and accountData: AccountData) async throws -> Context {
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accountData.accessToken ?? "")
        return try await client.getContext(for: statusId)
    }
    
    private func loadData(for accountData: AccountData, on backgroundContext: NSManagedObjectContext, minId: String? = nil, maxId: String? = nil) async throws {
        guard let accessToken = accountData.accessToken else {
            return
        }
                
        // Retrieve statuses from API.
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(maxId: maxId, minId: minId, limit: 20)
                
        // Download all images from server.
        let attachmentsData = await self.fetchAllImages(statuses: statuses)
        
        // Save status data in database.
        for status in statuses {
            let contains = attachmentsData.contains { (key: String, value: Data) in
                status.mediaAttachments.contains { attachment in
                    attachment.id == key
                }
            }
            
            // We are adding status only when we have at least one image for status.
            if contains == false {
                continue
            }
            
            let statusData = StatusDataHandler.shared.createStatusDataEntity(viewContext: backgroundContext)
            try await self.copy(from: status, to: statusData, attachmentsData: attachmentsData, on: backgroundContext)
        }
        
        try backgroundContext.save()
    }
    
    public func updateStatus(_ statusData: StatusData, basedOn status: Status) async throws -> StatusData? {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()
        
        // Download all images from server.
        let attachmentsData = await self.fetchAllImages(statuses: [status])
        
        // Update status data in database.
        try await self.copy(from: status, to: statusData, attachmentsData: attachmentsData, on: backgroundContext)
        try backgroundContext.save()
        
        return statusData
    }
    
    private func copy(from status: Status, to statusData: StatusData, attachmentsData: Dictionary<String, Data>, on backgroundContext: NSManagedObjectContext) async throws {
        statusData.copyFrom(status)
        
        for attachment in status.mediaAttachments {
            guard let imageData = attachmentsData[attachment.id] else {
                continue
            }
            
            // Save attachment in database.
            let attachmentData = statusData.attachments().first { item in item.id == attachment.id }
                ?? AttachmentDataHandler.shared.createAttachmnentDataEntity(viewContext: backgroundContext)
            
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
            
            if attachmentData.isInserted {
                attachmentData.statusRelation = statusData
                statusData.addToAttachmentRelation(attachmentData)
            }
        }
    }
    
    public func fetchAllImages(statuses: [Status]) async -> Dictionary<String, Data> {
        var attachmentUrls: Dictionary<String, URL> = [:]
        
        statuses.forEach { status in
            status.mediaAttachments.forEach { attachment in
                attachmentUrls[attachment.id] = attachment.url
            }
        }
        
        return await withTaskGroup(of: (String, Data?).self, returning: [String : Data].self) { taskGroup in            
            for attachmentUrl in attachmentUrls {
                taskGroup.addTask {
                    do {
                        if let imageData = try await self.fetchImage(attachmentUrl: attachmentUrl.value) {
                            return (attachmentUrl.key, imageData)
                        }
                        
                        return (attachmentUrl.key, nil)
                    } catch {
                        print("Error \(error.localizedDescription)")
                        return (attachmentUrl.key, nil)
                    }
                }
            }
            
            var childTaskResults = [String: Data]()
            for await result in taskGroup {
                guard let data = result.1 else {
                    continue
                }

                childTaskResults[result.0] = data
            }

            return childTaskResults
        }
    }
    
    private func fetchImage(attachmentUrl: URL) async throws -> Data? {
        guard let data = try await RemoteFileService.shared.fetchData(url: attachmentUrl) else {
            return nil
        }
        
        return data
    }
}
