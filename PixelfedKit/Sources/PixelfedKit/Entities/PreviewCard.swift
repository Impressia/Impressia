//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents a rich preview card that is generated using OpenGraph tags from a URL.
public struct PreviewCard: Codable {
    public enum PreviewCardType: String, Codable {
        case link = "link"
        case photo = "photo"
        case video = "video"
        case rich = "rich"
    }

    /// Location of linked resource.
    public let url: URL
    
    /// Title of linked resource.
    public let title: String
    
    /// Description of preview.
    public let description: String
    
    /// The type of the preview card.
    public let type: PreviewCardType

    /// The author of the original resource.
    public let authorName: String?
    
    /// A link to the author of the original resource.
    public let authorUrl: String?
    
    /// The provider of the original resource.
    public let providerName: String?
    
    /// A link to the provider of the original resource.
    public let providerUrl: String?
    
    /// HTML to be used for generating the preview card.
    public let html: String?
    
    /// Width of preview, in pixels.
    public let width: Int?
    
    /// Height of preview, in pixels.
    public let height: Int?
    
    /// Preview thumbnail.
    public let image: URL?
    
    /// Used for photo embeds, instead of custom html.
    public let embedUrl: URL?
    
    /// A hash computed by the [BlurHash](https://github.com/woltapp/blurhash) algorithm, for generating colorful preview thumbnails when media has not been downloaded yet.
    public let blurhash: String?

    private enum CodingKeys: String, CodingKey {
        case url
        case title
        case description
        case type

        case authorName     = "author_name"
        case authorUrl      = "author_url"
        case providerName   = "provider_name"
        case providerUrl    = "provider_url"
        case html
        case width
        case height
        case image
        case embedUrl       = "embed_url"
        case blurhash
    }
}
