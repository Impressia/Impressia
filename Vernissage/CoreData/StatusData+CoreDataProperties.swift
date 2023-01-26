//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import CoreData

extension StatusData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StatusData> {
        return NSFetchRequest<StatusData>(entityName: "StatusData")
    }

    @NSManaged public var accountAvatar: URL?
    @NSManaged public var accountDisplayName: String?
    @NSManaged public var accountId: String
    @NSManaged public var accountUsername: String
    @NSManaged public var applicationName: String?
    @NSManaged public var applicationWebsite: URL?
    @NSManaged public var bookmarked: Bool
    @NSManaged public var content: String
    @NSManaged public var createdAt: String
    @NSManaged public var favourited: Bool
    @NSManaged public var favouritesCount: Int32
    @NSManaged public var id: String
    @NSManaged public var inReplyToAccount: String?
    @NSManaged public var inReplyToId: String?
    @NSManaged public var muted: Bool
    @NSManaged public var pinned: Bool
    @NSManaged public var reblogged: Bool
    @NSManaged public var reblogsCount: Int32
    @NSManaged public var repliesCount: Int32
    @NSManaged public var sensitive: Bool
    @NSManaged public var spoilerText: String?
    @NSManaged public var uri: String?
    @NSManaged public var url: URL?
    @NSManaged public var visibility: String
    @NSManaged public var attachmentRelation: Set<AttachmentData>?
    @NSManaged public var pixelfedAccount: AccountData
    
    @NSManaged public var rebloggedStatusId: String?
    @NSManaged public var rebloggedAccountAvatar: URL?
    @NSManaged public var rebloggedAccountDisplayName: String?
    @NSManaged public var rebloggedAccountId: String?
    @NSManaged public var rebloggedAccountUsername: String?
}

// MARK: Generated accessors for attachmentRelation
extension StatusData {

    @objc(addAttachmentRelationObject:)
    @NSManaged public func addToAttachmentRelation(_ value: AttachmentData)

    @objc(removeAttachmentRelationObject:)
    @NSManaged public func removeFromAttachmentRelation(_ value: AttachmentData)

    @objc(addAttachmentRelation:)
    @NSManaged public func addToAttachmentRelation(_ values: NSSet)

    @objc(removeAttachmentRelation:)
    @NSManaged public func removeFromAttachmentRelation(_ values: NSSet)

}

extension StatusData : Identifiable {

}
