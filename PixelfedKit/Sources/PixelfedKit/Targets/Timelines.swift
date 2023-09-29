//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Timelines {
        case home(MaxId?, SinceId?, MinId?, Limit?, Bool?)
        case pub(Bool?, Bool?, Bool?, MaxId?, SinceId?, MinId?, Limit?)
        case tag(String, Bool?, Bool?, Bool?, MaxId?, SinceId?, MinId?, Limit?)
    }
}

extension Pixelfed.Timelines: TargetType {
    private var apiPath: String { return "/api/v1/timelines" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .home:
            return "\(apiPath)/home"
        case .pub:
            return "\(apiPath)/public"
        case .tag(let hashtag, _, _, _, _, _, _, _):
            return "\(apiPath)/tag/\(hashtag)"
        }
    }

    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        default:
            return .get
        }
    }

    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []
        var local: Bool?
        var remote: Bool?
        var onlyMedia: Bool?
        var includeReblogs: Bool?
        var maxId: MaxId?
        var sinceId: SinceId?
        var minId: MinId?
        var limit: Limit?

        switch self {
        case .tag(_, let paramLocal, let paramRemote, let paramOnlyMedia, let paramMaxId, let paramSinceId, let paramMinId, let paramLimit),
             .pub(let paramLocal, let paramRemote, let paramOnlyMedia, let paramMaxId, let paramSinceId, let paramMinId, let paramLimit):
            local = paramLocal
            remote = paramRemote
            onlyMedia = paramOnlyMedia
            maxId = paramMaxId
            sinceId = paramSinceId
            minId = paramMinId
            limit = paramLimit
        case .home(let paramMaxId, let paramSinceId, let paramMinId, let paramLimit, let paramIncludeReblogs):
            maxId = paramMaxId
            sinceId = paramSinceId
            minId = paramMinId
            limit = paramLimit
            includeReblogs = paramIncludeReblogs
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

        if let local {
            params.append(("local", local.asString))
        }

        if let remote {
            params.append(("remote", remote.asString))
        }

        if let onlyMedia {
            params.append(("only_media", onlyMedia.asString))
        }

        if let includeReblogs, includeReblogs == true {
            params.append(("include_reblogs", includeReblogs.asString))
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
