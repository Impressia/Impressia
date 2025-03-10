//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Bookmarks {
        case bookmarks(MaxId?, SinceId?, MinId?, Limit?)
    }
}

extension Pixelfed.Bookmarks: TargetType {
    private var apiPath: String { return "/api/v1/bookmarks" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .bookmarks:
            return "\(apiPath)"
        }
    }

    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .bookmarks:
            return .get
        }
    }

    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var maxId: MaxId?
        var sinceId: SinceId?
        var minId: MinId?
        var limit: Limit?

        switch self {
        case .bookmarks(let paramMaxId, let paramSinceId, let paramMinId, let paramLimit):
            maxId = paramMaxId
            sinceId = paramSinceId
            minId = paramMinId
            limit = paramLimit
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

        return params
    }

    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }

    public var httpBody: Data? {
        nil
    }
}
