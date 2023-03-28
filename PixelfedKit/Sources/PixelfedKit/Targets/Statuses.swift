//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Statuses {
        public enum Visibility: String, Encodable {
            case priv = "private"
            case unlisted = "unlisted"
            case pub = "public"
        }

        case status(EntityId)
        case context(EntityId)
        case card(EntityId)
        case rebloggedBy(EntityId, MaxId?, SinceId?, MinId?, Limit?, Page?)
        case favouritedBy(EntityId, MaxId?, SinceId?, MinId?, Limit?, Page?)
        case new(Components)
        case delete(EntityId)
        case reblog(EntityId)
        case unreblog(EntityId)
        case favourite(EntityId)
        case unfavourite(EntityId)
        case bookmark(EntityId)
        case unbookmark(EntityId)
        case pin(EntityId)
        case unpin(EntityId)
    }
}

extension Pixelfed.Statuses {
    public struct Components {
        public let inReplyToId: EntityId?
        public let text: String
        public let spoilerText: String
        public let mediaIds: [String]
        public let visibility: Visibility
        public let sensitive: Bool
        public let placeId: Int?
        public let commentsDisabled: Bool
        public let collectionIds: [Int]?

        public init(
            inReplyToId: EntityId? = nil,
            text: String,
            spoilerText: String = "",
            mediaIds: [String] = [],
            visibility: Visibility = .pub,
            sensitive: Bool = false,
            placeId: Int? = nil,
            commentsDisabled: Bool = false,
            collectionIds: [Int]? = nil) {
                self.inReplyToId = inReplyToId
                self.text = text
                self.spoilerText = spoilerText
                self.mediaIds = mediaIds
                self.visibility = visibility
                self.sensitive = sensitive
                self.placeId = placeId
                self.commentsDisabled = commentsDisabled
                self.collectionIds = collectionIds
            }
    }
}

extension Pixelfed.Statuses: TargetType {
    struct Request: Encodable {
        let status: String
        let inReplyToId: String?
        let mediaIds: [String]?
        let sensitive: Bool
        let spoilerText: String?
        let visibility: Visibility
        let placeId: Int?
        let commentsDisabled: Bool
        let collectionIds: [Int]?
        
        enum CodingKeys: String, CodingKey {
            case status
            case inReplyToId = "in_reply_to_id"
            case mediaIds = "media_ids"
            case sensitive
            case spoilerText = "spoiler_text"
            case visibility
            case placeId = "place_id"
            case commentsDisabled = "comments_disabled"
            case collectionIds = "collection_ids"
        }
        
        func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<Pixelfed.Statuses.Request.CodingKeys> = encoder.container(keyedBy: Pixelfed.Statuses.Request.CodingKeys.self)
            try container.encode(self.status, forKey: Pixelfed.Statuses.Request.CodingKeys.status)
            try container.encode(self.inReplyToId, forKey: Pixelfed.Statuses.Request.CodingKeys.inReplyToId)
            try container.encode(self.mediaIds, forKey: Pixelfed.Statuses.Request.CodingKeys.mediaIds)
            try container.encode(self.sensitive, forKey: Pixelfed.Statuses.Request.CodingKeys.sensitive)
            try container.encodeIfPresent(self.spoilerText, forKey: Pixelfed.Statuses.Request.CodingKeys.spoilerText)
            try container.encode(self.visibility, forKey: Pixelfed.Statuses.Request.CodingKeys.visibility)
            try container.encodeIfPresent(self.placeId, forKey: Pixelfed.Statuses.Request.CodingKeys.placeId)
            try container.encode(self.commentsDisabled, forKey: Pixelfed.Statuses.Request.CodingKeys.commentsDisabled)
            try container.encodeIfPresent(self.collectionIds, forKey: Pixelfed.Statuses.Request.CodingKeys.collectionIds)
        }
    }
    
    private var apiPath: String { return "/api/v1/statuses" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .status(let id):
            return "\(apiPath)/\(id)"
        case .context(let id):
            return "\(apiPath)/\(id)/context"
        case .card(let id):
            return "\(apiPath)/\(id)/card"
        case .rebloggedBy(let id, _, _, _, _, _):
            return "\(apiPath)/\(id)/reblogged_by"
        case .favouritedBy(let id, _, _, _, _, _):
            return "\(apiPath)/\(id)/favourited_by"
        case .new(_):
            return "\(apiPath)"
        case .delete(let id):
            return "\(apiPath)/\(id)"
        case .reblog(let id):
            return "\(apiPath)/\(id)/reblog"
        case .unreblog(let id):
            return "\(apiPath)/\(id)/unreblog"
        case .favourite(let id):
            return "\(apiPath)/\(id)/favourite"
        case .unfavourite(let id):
            return "\(apiPath)/\(id)/unfavourite"
        case .bookmark(let id):
            return "\(apiPath)/\(id)/bookmark"
        case .unbookmark(let id):
            return "\(apiPath)/\(id)/unbookmark"
        case .pin(let id):
            return "\(apiPath)/\(id)/pin"
        case .unpin(let id):
            return "\(apiPath)/\(id)/unpin"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .new(_),
                    .reblog(_),
                    .unreblog(_),
                    .favourite(_),
                    .unfavourite(_),
                    .bookmark(_),
                    .unbookmark(_),
                    .pin(_),
                    .unpin(_):
            return .post
        case .delete(_):
            return .delete
        default:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var maxId: MaxId? = nil
        var sinceId: SinceId? = nil
        var minId: MinId? = nil
        var limit: Limit? = nil
        var page: Page? = nil
        var pixelfedKey: Bool? = nil

        switch self {
        case .status(_):
            pixelfedKey = true
        case .favouritedBy(_, let _maxId, let _sinceId, let _minId, let _limit, let _page):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
            page = _page
        case .rebloggedBy(_, let _maxId, let _sinceId, let _minId, let _limit, let _page):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
            page = _page
        default:
            return nil
        }
        
        if let maxId {
            params.append(("max_id",  maxId))
        }

        if let sinceId {
            params.append(("since_id", sinceId))
        }

        if let minId {
            params.append(("min_id", minId))
        }

        if let limit {
            params.append(("limit", "\(limit)"))
        }

        if let page {
            params.append(("page", "\(page)"))
        }
        
        if pixelfedKey != nil {
            params.append(("_pe", "1"))
        }
        
        return params
    }
    
    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }
    
    public var httpBody: Data? {
        switch self {
        case .new(let components):
            return try? JSONEncoder().encode(
                Request(
                    status: components.text,
                    inReplyToId: components.inReplyToId,
                    mediaIds: components.mediaIds,
                    sensitive: components.sensitive,
                    spoilerText: components.spoilerText,
                    visibility: components.visibility,
                    placeId: components.placeId,
                    commentsDisabled: components.commentsDisabled,
                    collectionIds: components.collectionIds)
            )

        default:
            return nil
        }
    }
}
