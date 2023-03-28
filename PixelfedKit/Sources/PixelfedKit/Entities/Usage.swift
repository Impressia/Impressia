//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Usage data for this instance.
public struct Usage: Codable {

    /// Usage data related to users on this instance.
    public let users: UsageUsers
    
    private enum CodingKeys: String, CodingKey {
        case users
    }
}

// Usage data related to users on this instance.
public struct UsageUsers: Codable {
    
    /// The number of active users in the past 4 weeks.
    public let activeMonth: Int
    
    private enum CodingKeys: String, CodingKey {
        case activeMonth = "active_month"
    }
}
