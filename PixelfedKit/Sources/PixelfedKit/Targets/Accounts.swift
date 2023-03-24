//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

fileprivate let multipartBoundary = UUID().uuidString

extension Pixelfed {
    public enum Account {
        case account(EntityId)
        case verifyCredentials
        case followers(EntityId, MaxId?, SinceId?, MinId?, Limit?, Page?)
        case following(EntityId, MaxId?, SinceId?, MinId?, Limit?, Page?)
        case statuses(EntityId, Bool, Bool, MaxId?, SinceId?, MinId?, Limit?)
        case follow(EntityId)
        case unfollow(EntityId)
        case block(EntityId)
        case unblock(EntityId)
        case mute(EntityId)
        case unmute(EntityId)
        case relationships([EntityId])
        case search(SearchQuery, Int)
        case updateCredentials(String, String, Data?)
    }
}

extension Pixelfed.Account: TargetType {
    fileprivate var apiPath: String { return "/api/v1/accounts" }

    public var path: String {
        switch self {
        case .account(let id):
            return "\(apiPath)/\(id)"
        case .verifyCredentials:
            return "\(apiPath)/verify_credentials"
        case .followers(let id, _, _, _, _, _):
            return "\(apiPath)/\(id)/followers"
        case .following(let id, _, _, _, _, _):
            return "\(apiPath)/\(id)/following"
        case .statuses(let id, _, _, _, _, _, _):
            return "\(apiPath)/\(id)/statuses"
        case .follow(let id):
            return "\(apiPath)/\(id)/follow"
        case .unfollow(let id):
            return "\(apiPath)/\(id)/unfollow"
        case .block(let id):
            return "\(apiPath)/\(id)/block"
        case .unblock(let id):
            return "\(apiPath)/\(id)/unblock"
        case .mute(let id):
            return "\(apiPath)/\(id)/mute"
        case .unmute(let id):
            return "\(apiPath)/\(id)/unmute"
        case .relationships(_):
            return "\(apiPath)/relationships"
        case .search(_, _):
            return "\(apiPath)/search"
        case .updateCredentials(_, _, _):
            return "\(apiPath)/update_credentials"
        }
    }
    
    public var method: Method {
        switch self {
        case .follow(_), .unfollow(_), .block(_), .unblock(_), .mute(_), .unmute(_):
            return .post
        case .updateCredentials(_, _, _):
            return .patch
        default:
            return .get
        }
    }
        
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var maxId: MaxId? = nil
        var sinceId: SinceId? = nil
        var minId: MinId? = nil
        var limit: Limit? = nil
        var page: Page? = nil

        switch self {
        case .statuses(_, let onlyMedia, let excludeReplies, let _maxId, let _sinceId, let _minId, let _limit):
            params.append(contentsOf: [
                ("only_media", onlyMedia.asString),
                ("exclude_replies", excludeReplies.asString)
            ])
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
        case .relationships(let id):
            return id.map({ id in
                    ("id[]", id)
                })
        case .search(let query, let limit):
            return [
                ("q", query),
                ("limit", limit.asString)
            ]
        case .following(_, let _maxId, let _sinceId, let _minId, let _limit, let _page):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
            page = _page
        case .followers(_, let _maxId, let _sinceId, let _minId, let _limit, let _page):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
            page = _page
        case .updateCredentials(let displayName, let bio, _):
            return [
                ("display_name", displayName),
                ("note", bio)
            ]
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
        
        return params
    }
    
    public var headers: [String: String]? {
        switch self {
        case .updateCredentials(_, _, let image):
            if image != nil {
                return ["content-type": "multipart/form-data; boundary=\(multipartBoundary)"]
            } else {
                return ["content-type": "application/x-www-form-urlencoded"]
            }
        default:
            return [:].contentTypeApplicationJson
        }
    }
    
    public var httpBody: Data? {
        switch self {
        case .updateCredentials(_, _, let image):
            if let image {
                let formDataBuilder = MultipartFormData(boundary: multipartBoundary)
                formDataBuilder.addDataField(named: "file", fileName: "avatar.jpg", data: image, mimeType: "image/jpeg")
                return formDataBuilder.build()
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
