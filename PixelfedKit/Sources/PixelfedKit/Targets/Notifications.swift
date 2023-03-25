//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension Pixelfed {
    public enum Notifications {
        case notifications(MaxId?, SinceId?, MinId?, Limit?)
        case notification(String)
        case clear
    }
}

extension Pixelfed.Notifications: TargetType {
    private var apiPath: String { return "/api/v1/notifications" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .notifications:
            return "\(apiPath)"
        case .notification(let id):
            return "\(apiPath)/\(id)"
        case .clear:
            return "\(apiPath)/clear"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .notifications, .notification(_):
            return .get
        case .clear:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var maxId: MaxId? = nil
        var sinceId: SinceId? = nil
        var minId: MinId? = nil
        var limit: Limit? = nil
        
        switch self {
        case .notifications(let _maxId, let _sinceId, let _minId, let _limit):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
        default: break
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
            
        return params
    }
    
    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }
    
    public var httpBody: Data? {
        nil
    }
}
