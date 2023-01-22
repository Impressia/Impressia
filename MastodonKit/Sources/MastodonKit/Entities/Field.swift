//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

/// Additional metadata attached to a profile as name-value pairs.
public struct Field: Codable {
    
    /// The key of a given field’s key-value pair.
    public let name: String
    
    /// The value associated with the name key. Type: String (HTML).
    public let value: String
    
    /// Timestamp of when the server verified a URL value for a rel=“me” link.
    /// NULLABLE String (ISO 8601 Datetime) if value is a verified URL. Otherwise, null.
    public let verifiedAt: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case value
        case verifiedAt = "verified_at"
    }
}
