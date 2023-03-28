//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

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
        case updateCredentials(String, String, String, Bool, Data?)
        case updateAvatar(Data?)
    }
}

extension Pixelfed.Account: TargetType {
    private var apiPath: String { return "/api/v1/accounts" }
    private var multipartBoundary: String { "d76a15ab-d0d4-499a-a3c6-62a86d0d2a74" }

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
        case .updateCredentials(_, _, _, _, _):
            return "\(apiPath)/update_credentials"
        case .updateAvatar(_):
            return "\(apiPath)/update_credentials"
        }
    }
    
    public var method: Method {
        switch self {
        case .follow(_), .unfollow(_), .block(_), .unblock(_), .mute(_), .unmute(_):
            return .post
        case .updateCredentials(_, _, _, _, _), .updateAvatar(_):
            // Mastodon API uses PATCH, however in Pixelfed we have to use POST: https://github.com/pixelfed/pixelfed/issues/4250
            // Also it seems that we have to speparatelly save text fields and avatar(?).
            return .post
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
        case .updateCredentials(_, _, _, _, _), .updateAvatar(_):
            return [
                ("_pe", "1")
            ]
        case .account(_), .verifyCredentials:
            return [
                ("_pe", "1")
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
        case .updateCredentials(_, _, _, _, _), .updateAvatar(_):
            return ["content-type": "multipart/form-data; boundary=\(multipartBoundary)"]
        default:
            return [:].contentTypeApplicationJson
        }
    }
    
    public var httpBody: Data? {
        switch self {
        case .updateCredentials(let displayName, let bio, let website, let locked, let image):
            let formDataBuilder = MultipartFormData(boundary: multipartBoundary)
            
            formDataBuilder.addTextField(named: "display_name", value: displayName)
            formDataBuilder.addTextField(named: "note", value: bio)
            formDataBuilder.addTextField(named: "website", value: website)
            formDataBuilder.addTextField(named: "locked", value: locked ? "true" : "false")

            if let image {
                formDataBuilder.addDataField(named: "avatar", fileName: "avatar.jpg", data: image, mimeType: "image/jpeg")
            }

            return formDataBuilder.build()
        case .updateAvatar(let image):
            let formDataBuilder = MultipartFormData(boundary: multipartBoundary)
            
            if let image {
                formDataBuilder.addDataField(named: "avatar", fileName: "avatar.jpg", data: image, mimeType: "image/jpeg")
            }

            return formDataBuilder.build()
        default:
            return nil
        }
    }
}
