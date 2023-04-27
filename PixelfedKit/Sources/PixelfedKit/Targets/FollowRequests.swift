//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum FollowRequests {
        case followRequests(Limit?, Page?)
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
        case .authorize(let id):
            return "\(apiPath)/\(id)/authorize"
        case .reject(let id):
            return "\(apiPath)/\(id)/reject"
        }
    }

    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .followRequests:
            return .get
        case .authorize, .reject:
            return .post
        }
    }

    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var limit: Limit?
        var page: Page?

        switch self {
        case .followRequests(let paramLimit, let paramPage):
            limit = paramLimit
            page = paramPage
        default:
            return nil
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
        return nil
    }
}
