//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Mutes {
        case mutes(MaxId?, SinceId?, MinId?, Limit?, Page?)
    }
}

extension Pixelfed.Mutes: TargetType {
    private var apiPath: String { return "/api/v1/mutes" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .mutes:
            return "\(apiPath)"
        }
    }

    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .mutes:
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
        var page: Page?

        switch self {
        case .mutes(let _maxId, let _sinceId, let _minId, let _limit, let _page):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
            page = _page
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
