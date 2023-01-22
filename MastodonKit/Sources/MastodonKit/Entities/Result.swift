//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Search results.
public struct Result: Codable {
    
    /// List of accoutns.
    public let accounts: [Account]
    
    /// List od statuses.
    public let statuses: [Status]
    
    
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
