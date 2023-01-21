//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public typealias SinceId = EntityId
public typealias MaxId = EntityId
public typealias MinId = EntityId
public typealias Limit = Int
public typealias Page = Int

extension Mastodon {
    public enum Timelines {
        case home(MaxId?, SinceId?, MinId?, Limit?)
        case pub(Bool, Bool, Bool, MaxId?, SinceId?, MinId?, Limit?)
        case tag(String, Bool, Bool, Bool, MaxId?, SinceId?, MinId?, Limit?)
    }
}

extension Mastodon.Timelines: TargetType {
    fileprivate var apiPath: String { return "/api/v1/timelines" }

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
        var local: Bool? = nil
        var remote: Bool? = nil
        var onlyMedia: Bool? = nil
        var maxId: MaxId? = nil
        var sinceId: SinceId? = nil
        var minId: MinId? = nil
        var limit: Limit? = nil

        switch self {
        case .tag(_, let _local, let _remote, let _onlyMedia, let _maxId, let _sinceId, let _minId, let _limit),
             .pub(let _local, let _remote, let _onlyMedia, let _maxId, let _sinceId, let _minId, let _limit):
            local = _local
            remote = _remote
            onlyMedia = _onlyMedia
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
        case .home(let _maxId, let _sinceId, let _minId, let _limit):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
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
        if let local {
            params.append(("local", local.asString))
        }
        if let remote {
            params.append(("remote", remote.asString))
        }
        if let onlyMedia {
            params.append(("only_media", onlyMedia.asString))
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
