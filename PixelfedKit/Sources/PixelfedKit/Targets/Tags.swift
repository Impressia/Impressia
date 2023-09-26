//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Tags {
        case tag(Hashtag)
        case follow(Hashtag)
        case unfollow(Hashtag)
        case followed(MaxId?, SinceId?, MinId?, Limit?)
    }
}

extension Pixelfed.Tags: TargetType {
    private var apiPath: String { return "/api/v1/tags" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .tag(let hashtag):
            return "\(apiPath)/\(hashtag)"
        case .follow(let hashtag):
            return "\(apiPath)/\(hashtag)/follow"
        case .unfollow(let hashtag):
            return "\(apiPath)/\(hashtag)/unfollow"
        case .followed:
            return "/api/v1/followed_tags"
        }
    }

    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .tag, .followed(_, _, _, _):
            return .get
        case .follow, .unfollow:
            return .post
        }
    }

    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var maxId: MaxId?
        var sinceId: SinceId?
        var minId: MinId?
        var limit: Limit?

        switch self {
        case .followed(let paramMaxId, let paramSinceId, let paramMinId, let paramLimit):
            maxId = paramMaxId
            sinceId = paramSinceId
            minId = paramMinId
            limit = paramLimit
        default: break
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

        return params
    }

    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }

    public var httpBody: Data? {
        nil
    }
}
