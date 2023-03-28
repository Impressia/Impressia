//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation

/// Represents a status ID that, if matched, should cause the filter action to be taken.
public struct FilterStatus: Codable {
    
    /// The ID of the FilterStatus in the database.
    public let id: EntityId
    
    /// The ID of the filtered Status in the database.
    public let statusId: EntityId
    
    private enum CodingKeys: String, CodingKey {
        case id
        case statusId = "status_id"
    }
}
