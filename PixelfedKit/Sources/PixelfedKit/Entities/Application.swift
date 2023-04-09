//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents an application that interfaces with the REST API to access accounts or post statuses.
public class Application: BaseApplication {

    ///  The application id.
    public let id: String

    /// Where the user should be redirected after authorization. To display the authorization code to the user instead of redirecting to a web page,
    /// use urn:ietf:wg:oauth:2.0:oob in this parameter.
    public let redirectUri: String

    /// Client ID key, to be used for obtaining OAuth tokens.
    public let clientId: String

    /// Client secret key, to be used for obtaining OAuth tokens.
    public let clientSecret: String

    /// Used for Push Streaming API. Returned with POST /api/v1/apps. Equivalent to WebPushSubscription#server_key.
    public let vapidKey: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case redirectUri = "redirect_uri"
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case vapidKey = "vapid_key"
    }

    public init(clientId: String, clientSecret: String, redirectUri: String, vapidKey: String = "") {
        self.id = ""
        self.redirectUri = redirectUri
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.vapidKey = vapidKey

        super.init(name: "", website: nil)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.redirectUri = try container.decode(String.self, forKey: .redirectUri)
        self.clientId = try container.decode(String.self, forKey: .clientId)
        self.clientSecret = try container.decode(String.self, forKey: .clientSecret)
        self.vapidKey = try? container.decodeIfPresent(String.self, forKey: .vapidKey)

        try super.init(from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(redirectUri, forKey: .redirectUri)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(clientSecret, forKey: .clientSecret)

        if let vapidKey {
            try container.encode(vapidKey, forKey: .vapidKey)
        }
    }
}
