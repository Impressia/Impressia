//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Focal points for cropping media thumbnails.
/// https://docs.joinmastodon.org/api/guidelines/#focal-points
public struct Focus: Codable {

    /// X position int he image.
    public let xPoint: Int

    /// Y position in the image.
    public let yPoint: Int

    private enum CodingKeys: String, CodingKey {
        case xPoint = "x"
        case yPoint = "y"
    }
}
