//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum FollowRequests {
        case followRequests
        case authorize(String)
        case reject(String)
    }
}

extension Pixelfed.FollowRequests: TargetType {
    private var apiPath: String { return "/api/v1/follow_requests" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .followRequests:
            return "\(apiPath)"
        case .authorize(_):
            return "\(apiPath)/authorize"
        case .reject(_):
            return "\(apiPath)/reject"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .followRequests:
            return .get
        case .authorize(_), .reject(_):
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        nil
    }
    
    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }
    
    public var httpBody: Data? {
        switch self {
        case .followRequests:
            return nil
        case .authorize(let id):
            return try? JSONEncoder().encode(
                ["id": id]
            )
        case .reject:
            return nil
        }
    }
}
