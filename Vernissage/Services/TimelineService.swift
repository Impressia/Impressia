//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import CoreData
import MastodonSwift

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
        let statuses = try await client.getHomeTimeline(maxId: maxId, minId: minId, limit: 40)
                
        // Save status data in database.
        for status in statuses {
            let statusData = StatusDataHandler.shared.createStatusDataEntity(viewContext: backgroundContext)
            try await self.copy(from: status, to: statusData, on: backgroundContext)
        }
        
        try backgroundContext.save()
    }
    
    public func updateStatus(_ statusData: StatusData, basedOn status: Status) async throws -> StatusData? {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()
        
        // Update status data in database.
        try await self.copy(from: status, to: statusData, on: backgroundContext)
        try backgroundContext.save()
        
        return statusData
    }
    
    private func copy(from status: Status, to statusData: StatusData, on backgroundContext: NSManagedObjectContext) async throws {
        statusData.copyFrom(status)
        
        for attachment in status.mediaAttachments {
            let imageData = try await self.fetchImage(attachment: attachment)
            
            guard let imageData = imageData else {
                continue
            }
            
            // Save attachment in database.
            let attachmentData = statusData.attachments().first { item in item.id == attachment.id }
            ?? AttachmentDataHandler.shared.createAttachmnentDataEntity(viewContext: backgroundContext)
            
            attachmentData.copyFrom(attachment)
            attachmentData.statusId = statusData.id
            attachmentData.data = imageData
            
            // TODO: read exif information
            
            if attachmentData.isInserted {
                attachmentData.statusRelation = statusData
                statusData.addToAttachmentRelation(attachmentData)
            }
        }
    }
    
    private func fetchImage(attachment: Attachment) async throws -> Data? {
        guard let data = try await RemoteFileService.shared.fetchData(url: attachment.url) else {
            return nil
        }
        
        return data
    }
}
