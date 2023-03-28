//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Metadata returned by Paperclip. May contain subtrees small and original, as well as various other top-level properties.
/// More importantly, there may be another topl-level focus Hash object on images as of 2.3.0,
/// with coordinates can be used for smart thumbnail cropping – see Focal points for cropped media thumbnails for more.
public struct ImageMetadata: Metadata {
    
    /// Metadata about orginal image.
    public let original: ImageInfo?
    
    /// Metadata about small version of image.
    public let small: ImageInfo?
    
    /// Focal points for cropping media thumbnails.
    public let focus: Focus?

    private enum CodingKeys: String, CodingKey {
        case original
        case small
        case focus
    }
}
