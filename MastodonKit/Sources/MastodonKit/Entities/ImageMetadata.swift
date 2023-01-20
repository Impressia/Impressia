//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public struct ImageMetadata: Metadata {
    public let original: ImageInfo?
    public let small: ImageInfo?
    public let focus: Focus?

    private enum CodingKeys: String, CodingKey {
        case original
        case small
        case focus
    }
}
