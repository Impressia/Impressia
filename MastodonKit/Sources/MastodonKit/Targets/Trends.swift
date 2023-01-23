//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension Mastodon {
    public enum Trends {
        case tags(Offset?, Limit?)
        case statuses(Offset?, Limit?)
        case links(Offset?, Limit?)
    }
}

extension Mastodon.Trends: TargetType {
    fileprivate var apiPath: String { return "/api/v1/trends" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .tags(_, _):
            return "\(apiPath)/tags"
        case .statuses(_, _):
            return "\(apiPath)/statuses"
        case .links(_, _):
            return "\(apiPath)/links"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .tags, .statuses, .links:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var offset: Offset? = nil
        var limit: Limit? = nil

        switch self {
        case .tags(let _offset, let _limit):
            offset = _offset
            limit = _limit
        case .statuses(let _offset, let _limit):
            offset = _offset
            limit = _limit
        case .links(let _offset, let _limit):
            offset = _offset
            limit = _limit
        }
        
        if let offset {
            params.append(("offset",  "\(offset)"))
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
