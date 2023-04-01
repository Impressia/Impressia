//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Search {
        case search(SearchQuery, ResultsType, Bool, MaxId?, SinceId?, MinId?, Limit?, Page?)
    }
}

extension Pixelfed.Search: TargetType {
    public enum ResultsType: String {
        case accounts
        case hashtags
        case statuses
    }

    private var apiPath: String { return "/api/v2/search" }

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

        var maxId: MaxId?
        var sinceId: SinceId?
        var minId: MinId?
        var limit: Limit?
        var page: Page?

        switch self {
        case .search(let paramQuery,
                     let paramResultsType,
                     let paramResolveNonLocal,
                     let paramMaxId,
                     let paramSinceId,
                     let paramMinId,
                     let paramLimit,
                     let paramPage):

            params.append(contentsOf: [
                ("q", paramQuery),
                ("type", paramResultsType.rawValue),
                ("resolve", paramResolveNonLocal.asString)
            ])

            maxId = paramMaxId
            sinceId = paramSinceId
            minId = paramMinId
            limit = paramLimit
            page = paramPage
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
