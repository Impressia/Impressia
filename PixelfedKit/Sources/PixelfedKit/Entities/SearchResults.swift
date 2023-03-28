//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents the results of a search.
public struct SearchResults: Codable {
    
    /// Accounts which match the given query.
    public let accounts: [Account]
    
    /// Statuses which match the given query.
    public let statuses: [Status]
    
    /// Hashtags which match the given query
    public let hashtags: [Tag]

    public enum CodingKeys: CodingKey {
        case accounts
        case statuses
        case hashtags
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.accounts = (try? container.decode([Account].self, forKey: .accounts)) ?? []
        self.statuses = (try? container.decode([Status].self, forKey: .statuses)) ?? []
        self.hashtags = (try? container.decode([Tag].self, forKey: .hashtags)) ?? []
    }
}
