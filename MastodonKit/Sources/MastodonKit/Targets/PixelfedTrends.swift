//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension Mastodon {
    public enum PixelfedTrends {
        case statuses(TrendRange?)
    }
}

extension Mastodon.PixelfedTrends: TargetType {
    public enum TrendRange: String {
        case daily = "daily"
        case monthly = "monthly"
        case yearly = "yearly"
    }
    
    fileprivate var apiPath: String { return "/api/pixelfed/v2/discover/posts/trending" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .statuses(_):
            return "\(apiPath)"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .statuses:
            return .get
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var trendRange: TrendRange? = nil

        switch self {
        case .statuses(let _trendRange):
            trendRange = _trendRange
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
        
        return params
    }
    
    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }
    
    public var httpBody: Data? {
        nil
    }
}
