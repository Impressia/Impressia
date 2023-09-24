//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Account {
        case account(EntityId)
        case verifyCredentials
        case followers(EntityId, MaxId?, SinceId?, MinId?, Limit?, Page?)
        case following(EntityId, MaxId?, SinceId?, MinId?, Limit?, Page?)
        case statuses(EntityId, Bool?, Bool?, MaxId?, SinceId?, MinId?, Limit?)
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
        case .relationships:
            return "\(apiPath)/relationships"
        case .search:
            return "\(apiPath)/search"
        case .updateCredentials:
            return "\(apiPath)/update_credentials"
        case .updateAvatar:
            return "\(apiPath)/update_credentials"
        }
    }

    public var method: Method {
        switch self {
        case .follow, .unfollow, .block, .unblock, .mute, .unmute:
            return .post
        case .updateCredentials, .updateAvatar:
            // Mastodon API uses PATCH, however in Pixelfed we have to use POST:
            // https://github.com/pixelfed/pixelfed/issues/4250
            // Also it seems that we have to speparatelly save text fields and avatar(?).
            return .post
        default:
            return .get
        }
    }

    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var maxId: MaxId?
        var sinceId: SinceId?
        var minId: MinId?
        var limit: Limit?
        var page: Page?

        switch self {
        case .statuses(_, let paramOnlyMedia, let paramExcludeReplies, let paramMaxId, let paramSinceId, let paramMinId, let paramLimit):

            if let paramOnlyMedia {
                params.append(("only_media", paramOnlyMedia.asString))
            }

            if let paramExcludeReplies {
                params.append(("only_media", paramExcludeReplies.asString))
            }

            maxId = paramMaxId
            sinceId = paramSinceId
            minId = paramMinId
            limit = paramLimit
        case .relationships(let id):
            return id.map({ id in
                    ("id[]", id)
                })
        case .search(let query, let limit):
            return [
                ("q", query),
                ("limit", limit.asString)
            ]
        case .following(_, let paramMaxId, let paramSinceId, let paramMinId, let paramLimit, let paramPage):
            maxId = paramMaxId
            sinceId = paramSinceId
            minId = paramMinId
            limit = paramLimit
            page = paramPage
        case .followers(_, let paramMaxId, let paramSinceId, let paramMinId, let paramLimit, let paramPage):
            maxId = paramMaxId
            sinceId = paramSinceId
            minId = paramMinId
            limit = paramLimit
            page = paramPage
        case .updateCredentials, .updateAvatar:
            return [
                ("_pe", "1")
            ]
        case .account, .verifyCredentials:
            return [
                ("_pe", "1")
            ]
        default:
            return nil
        }

        if let maxId {
            params.append(("max_id", maxId))
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
        case .updateCredentials, .updateAvatar:
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
