//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the last read position within a user's timelines.
public struct Marker: Codable {
    
    /// The ID of the most recently viewed entity.
    public let lastReadId: EntityId
    
    /// An incrementing counter, used for locking to prevent write conflicts.
    public let version: Int64
    
    /// The timestamp of when the marker was set. String (ISO 8601 Datetime).
    public let updatedAt: String

    private enum CodingKeys: String, CodingKey {
        case lastReadId = "last_read_id"
        case version
        case updatedAt = "updated_at"
    }
}

public struct Markers: Codable {
    public let home: Marker?
    public let notifications: Marker?

    private enum CodingKeys: String, CodingKey {
        case home
        case notifications
    }
}
