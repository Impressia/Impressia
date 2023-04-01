//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Information about registering for this website.
public struct Registration: Codable {

    /// Whether registrations are enabled.
    public let enabled: Bool

    /// Whether registrations require moderator approval.
    public let approvalRequired: Bool

    /// A custom message to be shown when registrations are closed. String (HTML) or null.
    public let message: String?

    private enum CodingKeys: String, CodingKey {
        case enabled
        case approvalRequired = "approval_required"
        case message
    }
}
