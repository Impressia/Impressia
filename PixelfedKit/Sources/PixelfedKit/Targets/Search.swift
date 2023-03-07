//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension Pixelfed {
    public enum Search {
        case search(SearchQuery, ResultsType, Bool, MaxId?, SinceId?, MinId?, Limit?, Page?)
    }
}


extension Pixelfed.Search: TargetType {
    public enum ResultsType: String {
        case accounts = "accounts"
        case hashtags = "hashtags"
        case statuses = "statuses"
    }
    
    fileprivate var apiPath: String { return "/api/v2/search" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .search:
            return "\(apiPath)"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .search:
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
        case .search(let _query, let _resultsType, let _resolveNonLocal, let _maxId, let _sinceId, let _minId, let _limit, let _page):
            params.append(contentsOf: [
                ("q", _query),
                ("type", _resultsType.rawValue),
                ("resolve", _resolveNonLocal.asString)
            ])
            
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
