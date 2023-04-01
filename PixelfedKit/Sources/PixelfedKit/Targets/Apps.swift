//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Apps {
        case register(clientName: String, redirectUris: String, scopes: String?, website: String?)
    }
}

extension Pixelfed.Apps: TargetType {
    struct Request: Encodable {
        let clientName: String
        let redirectUris: String
        let scopes: String?
        let website: String?

        enum CodingKeys: String, CodingKey {
            case clientName = "client_name"
            case redirectUris = "redirect_uris"
            case scopes
            case website
        }

        func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<Pixelfed.Apps.Request.CodingKeys> = encoder.container(keyedBy: Pixelfed.Apps.Request.CodingKeys.self)
            try container.encode(self.clientName, forKey: Pixelfed.Apps.Request.CodingKeys.clientName)
            try container.encode(self.redirectUris, forKey: Pixelfed.Apps.Request.CodingKeys.redirectUris)
            try container.encode(self.scopes, forKey: Pixelfed.Apps.Request.CodingKeys.scopes)
            try container.encode(self.website, forKey: Pixelfed.Apps.Request.CodingKeys.website)
        }
    }

    private var apiPath: String { return "/api/v1/apps" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .register:
            return "\(apiPath)"
        }
    }

    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .register:
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
        case .register(let clientName, let redirectUris, let scopes, let website):
            return try? JSONEncoder().encode(
                Request(clientName: clientName, redirectUris: redirectUris, scopes: scopes, website: website)
            )
        }
    }
}
