//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation

/// Represents a rule that server users should follow.
public struct Rule: Codable {

    /// An identifier for the rule.
    public let id: EntityId
    
    /// The rule to be followed.
    public let text: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case text
    }
}
