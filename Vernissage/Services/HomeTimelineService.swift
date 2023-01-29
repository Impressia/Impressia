//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import CoreData
import MastodonKit

/// Service responsible for managing home timeline.
public class HomeTimelineService {
    public static let shared = HomeTimelineService()
    private init() { }
    
    public func loadOnBottom(for accountData: AccountData) async throws -> Int {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get maximimum downloaded stauts id.
        let oldestStatus = StatusDataHandler.shared.getMinimumStatus(accountId: accountData.id, viewContext: backgroundContext)
        
        guard let oldestStatus = oldestStatus else {
            return 0
        }
        
        let newStatuses = try await self.load(for: accountData, on: backgroundContext, maxId: oldestStatus.id)
        
        try backgroundContext.save()
        return newStatuses.count
    }

    public func loadOnTop(for accountData: AccountData) async throws {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Refresh/load home timeline (refreshing on top downloads always first 40 items).
        // TODO: When Apple introduce good way to show new items without scroll to top then we can change that method.
        try await self.refresh(for: accountData, on: backgroundContext)
        
        try backgroundContext.save()
    }
    
    public func update(status statusData: StatusData, basedOn status: Status, for accountData: AccountData) async throws -> StatusData? {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()
                
        // Update status data in database.
        self.copy(from: status, to: statusData, on: backgroundContext)
        try backgroundContext.save()
        
        return statusData
    }
    
    public func update(attachment: AttachmentData, withData imageData: Data) {
        attachment.data = imageData
        self.setExifProperties(in: attachment, from: imageData)
        
        CoreDataHandler.shared.save()
    }
    
    private func refresh(for accountData: AccountData, on backgroundContext: NSManagedObjectContext) async throws {
        guard let accessToken = accountData.accessToken else {
            return
        }
        
        // Retrieve statuses from API.
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(limit: 40)
        
        // Retrieve all statuses from database.
        let dbStatuses = StatusDataHandler.shared.getAllStatuses(accountId: accountData.id)
        
        // Remove statuses that are not in 40 downloaded once.
        var dbStatusesToRemove: [StatusData] = []
        for dbStatus in dbStatuses {
            if !statuses.contains(where: { status in status.id == dbStatus.id }) {
                dbStatusesToRemove.append(dbStatus)
            }
        }
        
        if !dbStatusesToRemove.isEmpty {
            StatusDataHandler.shared.remove(accountId: accountData.id, statuses: dbStatusesToRemove)
        }
        
        // Add statuses which are not existing in database, but has been downloaded via API.
        var statusesToAdd: [Status] = []
        for status in statuses {
            if !dbStatuses.contains(where: { statusData in statusData.id == status.id }) {
                statusesToAdd.append(status)
            }
        }
        
        // Save statuses in database.
        if !statusesToAdd.isEmpty {
            _ = try await self.save(statuses: statusesToAdd, for: accountData, on: backgroundContext)
        }
    }
    
    private func load(for accountData: AccountData,
                      on backgroundContext: NSManagedObjectContext,
                      minId: String? = nil,
                      maxId: String? = nil
    ) async throws -> [Status] {
        guard let accessToken = accountData.accessToken else {
            return []
        }
                
        // Retrieve statuses from API.
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(maxId: maxId, minId: minId, limit: 20)

        // Save statuses in database.
        return try await self.save(statuses: statuses, for: accountData, on: backgroundContext)
    }
    
    private func save(statuses: [Status],
                      for accountData: AccountData,
                      on backgroundContext: NSManagedObjectContext
    ) async throws -> [Status] {
        guard let dbAccount = AccountDataHandler.shared.getAccountData(accountId: accountData.id, viewContext: backgroundContext) else {
            throw DatabaseError.cannotDownloadAccount
        }
        
        // Proceed statuses with images only.
        let statusesWithImages = statuses.getStatusesWithImagesOnly()
                        
        // Save status data in database.
        for status in statusesWithImages {
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
                statusData.addToAttachmentsRelation(attachmentData)
            }
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
}
