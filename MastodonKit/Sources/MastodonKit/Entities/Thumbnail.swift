//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

/// An image used to represent this instance.
public struct Thumbnail: Codable {
    
    /// The URL for the thumbnail image.
    public let url: URL
    
    /// A hash computed by the [BlurHash](https://github.com/woltapp/blurhash) algorithm, for generating colorful preview thumbnails when media has not been downloaded yet.
    public let blurhash: String?
    
    /// Links to scaled resolution images, for high DPI screens.
    public let versions: ThumbnailVersions?
    
    private enum CodingKeys: String, CodingKey {
        case url
        case blurhash
        case versions
    }
}

/// Links to scaled resolution images, for high DPI screens.
public struct ThumbnailVersions: Codable {
    
    /// The URL for the thumbnail image at 1x resolution.
    public let x1: URL?
    
    /// The URL for the thumbnail image at 2x resolution.
    public let x2: URL?
    
    private enum CodingKeys: String, CodingKey {
        case x1 = "@1x"
        case x2 = "@2x"
    }
}
