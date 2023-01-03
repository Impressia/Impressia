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
    
    public func getComments(for statusId: String, and accountData: AccountData) async throws -> Context {
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accountData.accessToken ?? "")
        return try await client.getContext(for: statusId)
    }
    
    private func loadData(for accountData: AccountData, on backgroundContext: NSManagedObjectContext, minId: String? = nil, maxId: String? = nil) async throws {
        guard let accessToken = accountData.accessToken else {
            return
        }
        
        // Get maximimum downloaded stauts id.
        let attachmentDataHandler = AttachmentDataHandler()
        let statusDataHandler = StatusDataHandler()
        
        // Retrieve statuses from API.
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accessToken)
        let statuses = try await client.getHomeTimeline(maxId: maxId, minId: minId, limit: 40)
        
        // Download status images and save it into database.
        for status in statuses {
            
            // Save status data in database.
            let statusDataEntity = statusDataHandler.createStatusDataEntity(viewContext: backgroundContext)
            statusDataEntity.accountAvatar = status.account?.avatar
            statusDataEntity.accountDisplayName = status.account?.displayName
            statusDataEntity.accountId = status.account!.id
            statusDataEntity.accountUsername = status.account!.username
            statusDataEntity.applicationName = status.application?.name
            statusDataEntity.applicationWebsite = status.application?.website
            statusDataEntity.bookmarked = status.bookmarked
            statusDataEntity.content = status.content
            statusDataEntity.createdAt = status.createdAt
            statusDataEntity.favourited = status.favourited
            statusDataEntity.favouritesCount = Int32(status.favouritesCount)
            statusDataEntity.id = status.id
            statusDataEntity.inReplyToAccount = status.inReplyToAccount
            statusDataEntity.inReplyToId = status.inReplyToId
            statusDataEntity.muted = status.muted
            statusDataEntity.pinned = status.pinned
            statusDataEntity.reblogged = status.reblogged
            statusDataEntity.reblogsCount = Int32(status.reblogsCount)
            statusDataEntity.repliesCount = Int32(status.repliesCount)
            statusDataEntity.sensitive = status.sensitive
            statusDataEntity.spoilerText = status.spoilerText
            statusDataEntity.uri = status.uri
            statusDataEntity.url = status.url
            statusDataEntity.visibility = status.visibility.rawValue
            
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
                let attachmentData = attachmentDataHandler.createAttachmnentDataEntity(viewContext: backgroundContext)
                attachmentData.id = attachment.id
                attachmentData.url = attachment.url
                attachmentData.blurhash = attachment.blurhash
                attachmentData.previewUrl = attachment.previewUrl
                attachmentData.remoteUrl = attachment.remoteUrl
                attachmentData.text = attachment.description
                attachmentData.type = attachment.type.rawValue
                
                attachmentData.statusId = statusDataEntity.id
                attachmentData.data = imageData
                
                attachmentData.statusRelation = statusDataEntity
                statusDataEntity.addToAttachmentRelation(attachmentData)
            }
        }
        
        try backgroundContext.save()
    }
    
    private func fetchImage(attachment: Attachment) async throws -> Data? {
        guard let data = try await RemoteFileService.shared.fetchData(url: attachment.url) else {
            return nil
        }
        
        return data
    }
}
