//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public struct Focus: Codable {
    public let x: Int
    public let y: Int

    private enum CodingKeys: String, CodingKey {
        case x
        case y
    }
}
