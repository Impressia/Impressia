//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public struct ImageInfo: Codable {
    public let width: Int
    public let height: Int
    public let size: String
    public let aspect: Double

    private enum CodingKeys: String, CodingKey {
        case width
        case height
        case size
        case aspect
    }
}
