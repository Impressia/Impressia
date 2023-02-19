//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension Pixelfed {
    public enum Favourites {
        case favourites(MaxId?, SinceId?, MinId?, Limit?, Page?)
    }
}

extension Pixelfed.Favourites: TargetType {
    fileprivate var apiPath: String { return "/api/v1/favourites" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .favourites(_, _, _, _, _):
            return "\(apiPath)"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .favourites:
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

        switch self {
        case .favourites(let _maxId, let _sinceId, let _minId, let _limit, let _page):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
            page = _page
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
        [:].contentTypeApplicationJson
    }
    
    public var httpBody: Data? {
        nil
    }
}
