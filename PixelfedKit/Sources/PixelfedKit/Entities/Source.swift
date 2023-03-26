//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// An extra attribute that contains source values to be used with API methods that verify credentials and update credentials.
public struct Source: Codable {

    /// Profile bio, in plain-text instead of in HTML.
    public let note: String
        
    private enum CodingKeys: String, CodingKey {
        case note
    }
}
