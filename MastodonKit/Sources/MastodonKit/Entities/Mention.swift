//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public struct Mention: Codable {
    public let url: String
    public let username: String
    public let acct: String
    public let id: String
}
