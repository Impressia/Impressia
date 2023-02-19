//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the tree around a given status. Used for reconstructing threads of statuses.
public struct Context: Codable {
    
    /// Parents in the thread.
    public let ancestors: [Status]
    
    /// Children in the thread.
    public let descendants: [Status]

    public enum CodingKeys: CodingKey {
        case ancestors
        case descendants
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.ancestors = try container.decode([Status].self, forKey: .ancestors)
        self.descendants = try container.decode([Status].self, forKey: .descendants)
    }
}
