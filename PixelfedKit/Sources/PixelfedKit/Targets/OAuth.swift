//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

extension Pixelfed {
    public enum OAuth {
        case authenticate(Application, UsernameType, PasswordType, String?)
    }
}

extension Pixelfed.OAuth: TargetType {
    struct Request: Encodable {
        let clientId: String
        let clientSecret: String
        let grantType: String
        let username: String
        let password: String
        let scope: String
        
        enum CodingKeys: String, CodingKey {
            case clientId = "client_id"
            case clientSecret = "client_secret"
            case grantType = "grant_type"
            case username
            case password
            case scope
        }
        
        func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<Pixelfed.OAuth.Request.CodingKeys> = encoder.container(keyedBy: Pixelfed.OAuth.Request.CodingKeys.self)
            try container.encode(self.clientId, forKey: Pixelfed.OAuth.Request.CodingKeys.clientId)
            try container.encode(self.clientSecret, forKey: Pixelfed.OAuth.Request.CodingKeys.clientSecret)
            try container.encode(self.grantType, forKey: Pixelfed.OAuth.Request.CodingKeys.grantType)
            try container.encode(self.username, forKey: Pixelfed.OAuth.Request.CodingKeys.username)
            try container.encode(self.password, forKey: Pixelfed.OAuth.Request.CodingKeys.password)
            try container.encode(self.scope, forKey: Pixelfed.OAuth.Request.CodingKeys.scope)
        }
    }
    
    private var apiPath: String { return "/oauth/token" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case.authenticate(_, _, _, _):
            return "\(apiPath)"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .authenticate(_, _, _, _):
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
        case .authenticate(let app, let username, let password, let scope):
            return try? JSONEncoder().encode(
                Request(
                    clientId: app.clientId,
                    clientSecret: app.clientSecret,
                    grantType: "password",
                    username: username,
                    password: password,
                    scope: scope ?? ""
                )
            )
        }
    }
}
