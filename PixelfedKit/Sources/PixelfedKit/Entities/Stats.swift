//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation

/// Instance stats.
public struct Stats: Codable {
    
    /// Number of user in the instance.
    public let userCount: Int
    
    /// Number of statuses in the instance.
    public let statusCount: Int
    
    /// Number of domains?
    public let domainCount: Int

    private enum CodingKeys: String, CodingKey {
        case userCount = "user_count"
        case statusCount = "status_count"
        case domainCount = "domain_count"
    }
}

