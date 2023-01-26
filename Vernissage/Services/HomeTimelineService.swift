//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import CoreData
import MastodonKit

public class HomeTimelineService {
    public static let shared = HomeTimelineService()
    private init() { }
    
    public func onBottomOfList(for accountData: AccountData) async throws -> Int {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get maximimum downloaded stauts id.
        let oldestStatus = StatusDataHandler.shared.getMinimumStatus(accountId: accountData.id, viewContext: backgroundContext)
        
        guard let oldestStatus = oldestStatus else {
            return 0
        }
        
        let newStatuses = try await self.loadData(for: accountData, on: backgroundContext, maxId: oldestStatus.id)
        
        try backgroundContext.save()
        return newStatuses.count
    }

    public func onTopOfList(for accountData: AccountData) async throws -> Int {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get maximimum downloaded stauts id.
        let newestStatus = StatusDataHandler.shared.getMaximumStatus(accountId: accountData.id, viewContext: backgroundContext)
                
        let newStatuses = try await self.loadData(for: accountData, on: backgroundContext, minId: newestStatus?.id)
        try await self.clearOldStatuses(newStatuses: newStatuses, for: accountData, on: backgroundContext)
        
        try backgroundContext.save()
        return newStatuses.count
    }
    
    private func clearOldStatuses(newStatuses: [Status], for accountData: AccountData, on backgroundContext: NSManagedObjectContext) async throws {
        guard let accessToken = accountData.accessToken else {
            return
        }
        
        // Retrieve statuses from API.
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(limit: 40)
        
        let dbStatuses = StatusDataHandler.shared.getAllStatuses(accountId: accountData.id)
        
        var dbStatusesToRemove: [StatusData] = []
        for dbStatus in dbStatuses {
            if !statuses.contains(where: { status in status.id == dbStatus.id }) {
                dbStatusesToRemove.append(dbStatus)
            }
        }
        
        // Remove statuses that are not in 40 downloaded once.
        if !dbStatusesToRemove.isEmpty {
            StatusDataHandler.shared.remove(accountId: accountData.id, statuses: dbStatusesToRemove)
        }
        
        // Add statuses which are not existing in database, but has been downloaded via API.
        var statusesToAdd: [Status] = []
        for status in statuses {
            if !dbStatuses.contains(where: { statusData in statusData.id == status.id }) &&
                !newStatuses.contains(where: { newStatus in newStatus.id == status.id }) {
                statusesToAdd.append(status)
            }
        }
        
        // Save statuses in database (and download images).
        if !statusesToAdd.isEmpty {
            _ = try await self.save(statuses: statusesToAdd, accountData: accountData, on: backgroundContext)
        }
    }
    
    private func loadData(for accountData: AccountData, on backgroundContext: NSManagedObjectContext, minId: String? = nil, maxId: String? = nil) async throws -> [Status] {
        guard let accessToken = accountData.accessToken else {
            return []
        }
                
        // Retrieve statuses from API.
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(maxId: maxId, minId: minId, limit: 20)

        // Save statuses in database (and download images).
        return try await self.save(statuses: statuses, accountData: accountData, on: backgroundContext)
    }
    
    public func updateStatus(_ statusData: StatusData, accountData: AccountData, basedOn status: Status) async throws -> StatusData? {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()
                
        // Update status data in database.
        self.copy(from: status, to: statusData, on: backgroundContext)
        try backgroundContext.save()
        
        return statusData
    }
    
    public func updateAttachmentDataImage(attachmentData: AttachmentData, imageData: Data) {        
        attachmentData.data = imageData
        self.setExifProperties(in: attachmentData, from: imageData)
        
        CoreDataHandler.shared.save()
    }
    
    private func save(statuses: [Status], accountData: AccountData, on backgroundContext: NSManagedObjectContext) async throws -> [Status] {
        // Proceed statuses with images only.
        let statusesWithImages = statuses.getStatusesWithImagesOnly()
                        
        // Save status data in database.
        for status in statusesWithImages {
            guard let dbAccount = AccountDataHandler.shared.getAccountData(accountId: accountData.id, viewContext: backgroundContext) else {
                throw DatabaseError.cannotDownloadAccount
            }
            
            let statusData = StatusDataHandler.shared.createStatusDataEntity(viewContext: backgroundContext)

            statusData.pixelfedAccount = dbAccount
            dbAccount.addToStatuses(statusData)
            
            self.copy(from: status, to: statusData, on: backgroundContext)
        }
        
        return statusesWithImages
    }
    
    private func copy(from status: Status,
                      to statusData: StatusData,
                      on backgroundContext: NSManagedObjectContext
    ) {
        statusData.copyFrom(status)
        
        for attachment in status.getAllImageMediaAttachments() {
            
            // Save attachment in database.
            let attachmentData = statusData.attachments().first { item in item.id == attachment.id }
                ?? AttachmentDataHandler.shared.createAttachmnentDataEntity(viewContext: backgroundContext)
            
            attachmentData.copyFrom(attachment)
            attachmentData.statusId = statusData.id
                        
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
                if attachment.type == .image {
                    attachmentUrls[attachment.id] = attachment.url
                }
            }
        }
        
        return await withTaskGroup(of: (String, Data?).self, returning: [String : Data].self) { taskGroup in            
            for attachmentUrl in attachmentUrls {
                taskGroup.addTask {
                    do {
                        print("Fetching image \(attachmentUrl.value)")
                        if let imageData = try await self.fetchImage(attachmentUrl: attachmentUrl.value) {
                            print("Image fetched \(attachmentUrl.value)")
                            return (attachmentUrl.key, imageData)
                        }
                        
                        return (attachmentUrl.key, nil)
                    } catch {
                        ErrorService.shared.handle(error, message: "Fatching image '\(attachmentUrl.value)' failed.")
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
    
    private func setExifProperties(in attachmentData: AttachmentData, from imageData: Data) {
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
    }
    
    private func fetchImage(attachmentUrl: URL) async throws -> Data? {
        guard let data = try await RemoteFileService.shared.fetchData(url: attachmentUrl) else {
            return nil
        }
        
        return data
    }
}
