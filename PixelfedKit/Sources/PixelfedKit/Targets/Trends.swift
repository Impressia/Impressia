//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Trends {
        case tags(TrendRange?, Offset?, Limit?)
        case statuses(TrendRange?, Offset?, Limit?)
        case accounts(TrendRange?, Offset?, Limit?)
    }
}

extension Pixelfed.Trends: TargetType {
    public enum TrendRange: String {
        case daily = "daily"
        case monthly = "monthly"
        case yearly = "yearly"
    }
    
    private var apiPath: String { return "/api/v1.1/discover" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .tags(_, _, _):
            return "\(apiPath)/posts/hashtags"
        case .statuses(_, _, _):
            return "\(apiPath)/posts/trending"
        case .accounts(_, _, _):
            return "\(apiPath)/accounts/popular"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .tags, .statuses, .accounts:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []
        var trendRange: TrendRange? = nil

        var offset: Offset? = nil
        var limit: Limit? = nil

        switch self {
        case .tags(let _trendRange, let _offset, let _limit):
            trendRange = _trendRange
            offset = _offset
            limit = _limit
        case .statuses(let _trendRange, let _offset, let _limit):
            trendRange = _trendRange
            offset = _offset
            limit = _limit
        case .accounts(let _trendRange, let _offset, let _limit):
            trendRange = _trendRange
            offset = _offset
            limit = _limit
        }
        
        switch trendRange {
        case .daily:
            params.append(("range", "daily"))
        case .monthly:
            params.append(("range", "monthly"))
        case .yearly:
            params.append(("range", "yearly"))
        case .none:
            params.append(("range", "daily"))
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
