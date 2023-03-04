//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a hashtag used within the content of a status.
public struct Tag: Codable {

    /// The value of the hashtag after the # sign.
    public let name: String
    
    /// A link to the hashtag on the instance.
    public let url: URL?
    
    /// Usage statistics for given days (typically the past week).
    public let history: [TagHistory]?
    
    /// Whether the current token’s authorized user is following this tag.
    public let following: Bool?
}

/// Usage statistics for given days.
public struct TagHistory: Codable {

    /// UNIX timestamp on midnight of the given day.
    public let day: String
    
    /// The counted usage of the tag within that day.
    public let uses: String
    
    /// The total of accounts using the tag within that day (cast from an integer).
    public let accounts: String
}
