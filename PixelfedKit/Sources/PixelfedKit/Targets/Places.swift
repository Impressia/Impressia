//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Places {
        case search(SearchQuery)
    }
}

extension Pixelfed.Places: TargetType {
    private var apiPath: String { return "/api/v1.1/compose/search/location" }

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
        switch self {
        case .search(let query):
            return [
                ("q", query)
            ]
        }
    }

    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }

    public var httpBody: Data? {
        nil
    }
}
