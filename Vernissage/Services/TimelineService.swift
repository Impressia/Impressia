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
    
    public func onBottomOfList(for accountData: AccountData) async throws {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get maximimum downloaded stauts id.
        let statusDataHandler = StatusDataHandler()
        let oldestStatus = statusDataHandler.getMinimumtatus(viewContext: backgroundContext)
        
        guard let oldestStatus = oldestStatus else {
            return
        }
        
        try await self.loadData(for: accountData, on: backgroundContext, maxId: oldestStatus.id)
    }

    public func onTopOfList(for accountData: AccountData) async throws {
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get maximimum downloaded stauts id.
        let statusDataHandler = StatusDataHandler()
        let newestStatus = statusDataHandler.getMaximumStatus(viewContext: backgroundContext)
                
        try await self.loadData(for: accountData, on: backgroundContext, minId: newestStatus?.id)
    }
    
    public func getStatus(withId statusId: String, and accountData: AccountData) async throws -> Status? {
        guard let accessToken = accountData.accessToken else {
            return nil
        }

        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        return try await client.read(statusId: statusId)
    }
    
    public func updateStatus(statusData: StatusData, and accountData: AccountData) async throws -> StatusData? {
        guard let accessToken = accountData.accessToken else {
            return nil
        }
        
        // Load data from API and operate on CoreData on background context.
        let backgroundContext = CoreDataHandler.shared.newBackgroundContext()

        // Get new information from API.
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        let status = try await client.read(statusId: statusData.id)
        
        // Update status data in database.
        try await self.updateStatusData(from: status, to: statusData, on: backgroundContext)
        try backgroundContext.save()
        
        return statusData
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
        
        // Create handler for managing statuses in database.
        let statusDataHandler = StatusDataHandler()
        
        // Save status data in database.
        for status in statuses {
            let statusData = statusDataHandler.createStatusDataEntity(viewContext: backgroundContext)
            try await self.updateStatusData(from: status, to: statusData, on: backgroundContext)
        }
        
        try backgroundContext.save()
    }
    
    private func updateStatusData(from status: Status, to statusData: StatusData, on backgroundContext: NSManagedObjectContext) async throws {
        statusData.id = status.id
        statusData.createdAt = status.createdAt
        statusData.accountAvatar = status.account?.avatar
        statusData.accountDisplayName = status.account?.displayName
        statusData.accountId = status.account!.id
        statusData.accountUsername = status.account!.username
        statusData.applicationName = status.application?.name
        statusData.applicationWebsite = status.application?.website
        statusData.bookmarked = status.bookmarked
        statusData.content = status.content
        statusData.favourited = status.favourited
        statusData.favouritesCount = Int32(status.favouritesCount)
        statusData.inReplyToAccount = status.inReplyToAccount
        statusData.inReplyToId = status.inReplyToId
        statusData.muted = status.muted
        statusData.pinned = status.pinned
        statusData.reblogged = status.reblogged
        statusData.reblogsCount = Int32(status.reblogsCount)
        statusData.repliesCount = Int32(status.repliesCount)
        statusData.sensitive = status.sensitive
        statusData.spoilerText = status.spoilerText
        statusData.uri = status.uri
        statusData.url = status.url
        statusData.visibility = status.visibility.rawValue
        
        let attachmentDataHandler = AttachmentDataHandler()
        
        for attachment in status.mediaAttachments {
            let imageData = try await self.fetchImage(attachment: attachment)
            
            guard let imageData = imageData else {
                continue
            }
            
            /*
             var exif = image.getExifData()
             if let dict = exif as? [String: AnyObject] {
             dict.keys.map { key in
             print(key)
             print(dict[key])
             }
             }
             */
            
            // Save attachment in database.
            let attachmentData = statusData.attachments().first { item in item.id == attachment.id }
                ?? attachmentDataHandler.createAttachmnentDataEntity(viewContext: backgroundContext)
            
            attachmentData.id = attachment.id
            attachmentData.url = attachment.url
            attachmentData.blurhash = attachment.blurhash
            attachmentData.previewUrl = attachment.previewUrl
            attachmentData.remoteUrl = attachment.remoteUrl
            attachmentData.text = attachment.description
            attachmentData.type = attachment.type.rawValue
            
            attachmentData.statusId = statusData.id
            attachmentData.data = imageData
            
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
