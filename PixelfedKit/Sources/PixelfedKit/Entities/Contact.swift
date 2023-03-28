//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    

import Foundation

/// Hints related to contacting a representative of the website.
public struct Contact: Codable {
    
    /// An email address that can be messaged regarding inquiries or issues.
    public let email: String;
    
    /// An account that can be contacted natively over the network regarding inquiries or issues.
    public let account: Account
    
    private enum CodingKeys: String, CodingKey {
        case email
        case account
    }
}
