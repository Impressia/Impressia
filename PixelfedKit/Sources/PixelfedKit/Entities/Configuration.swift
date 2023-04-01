//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Configured values and limits for this website.
public struct Configuration: Codable {

    /// URLs of interest for clients apps.
    public let urls: ConfigurationUrls?

    /// Limits related to accounts.
    public let accounts: ConfigurationAccounts?

    /// Limits related to authoring statuses.
    public let statuses: ConfigurationStatuses?

    /// Hints for which attachments will be accepted.
    public let mediaAttachments: ConfigurationMediaAttachments?

    /// Limits related to polls.
    public let polls: ConfigurationPolls?

    /// Hints related to translation.
    public let translation: ConfigurationTranslation?

    private enum CodingKeys: String, CodingKey {
        case urls
        case accounts
        case statuses
        case mediaAttachments = "media_attachments"
        case polls
        case translation
    }
}

/// URLs of interest for clients apps.
public struct ConfigurationUrls: Codable {

    /// The Websockets URL for connecting to the streaming API.
    public let streaming: String?

    private enum CodingKeys: String, CodingKey {
        case streaming
    }
}

/// Limits related to accounts.
public struct ConfigurationAccounts: Codable {

    /// The maximum number of featured tags allowed for each account.
    public let maxFeaturedTags: Int?

    private enum CodingKeys: String, CodingKey {
        case maxFeaturedTags = "max_featured_tags"
    }
}

/// Limits related to authoring statuses.
public struct ConfigurationStatuses: Codable {

    /// The maximum number of allowed characters per status.
    public let maxCharacters: Int

    /// The maximum number of media attachments that can be added to a status.
    public let maxMediaAttachments: Int

    /// Each URL in a status will be assumed to be exactly this many characters.
    public let charactersReservedPerUrl: Int

    private enum CodingKeys: String, CodingKey {
        case maxCharacters = "max_characters"
        case maxMediaAttachments = "max_media_attachments"
        case charactersReservedPerUrl = "characters_reserved_per_url"
    }
}

/// Hints for which attachments will be accepted.
public struct ConfigurationMediaAttachments: Codable {

    /// Contains MIME types that can be uploaded.
    public let supportedMimeTypes: [String]?

    /// The maximum size of any uploaded image, in bytes.
    public let imageSizeLimit: Int

    /// The maximum number of pixels (width times height) for image uploads.
    public let imageMatrixLimit: Int

    /// The maximum size of any uploaded video, in bytes.
    public let videoSizeLimit: Int

    /// The maximum frame rate for any uploaded video.
    public let videoFrameRateLimit: Int

    /// The maximum number of pixels (width times height) for video uploads.
    public let videoMatrixLimit: Int

    private enum CodingKeys: String, CodingKey {
        case supportedMimeTypes = "supported_mime_types"
        case imageSizeLimit = "image_size_limit"
        case imageMatrixLimit = "image_matrix_limit"
        case videoSizeLimit = "video_size_limit"
        case videoFrameRateLimit = "video_frame_rate_limit"
        case videoMatrixLimit = "video_matrix_limit"
    }
}

/// Limits related to polls.
public struct ConfigurationPolls: Codable {

    /// Each poll is allowed to have up to this many options.
    public let maxOptions: Int

    /// Each poll option is allowed to have this many characters.
    public let maxCharactersPerOption: Int

    /// The shortest allowed poll duration, in seconds.
    public let minExpiration: Int

    /// The longest allowed poll duration, in seconds.
    public let maxExpiration: Int

    private enum CodingKeys: String, CodingKey {
        case maxOptions = "max_options"
        case maxCharactersPerOption = "max_characters_per_option"
        case minExpiration = "min_expiration"
        case maxExpiration = "max_expiration"
    }
}

/// Hints related to translation.
public struct ConfigurationTranslation: Codable {

    /// Whether the Translations API is available on this instance.
    public let enabled: Bool

    private enum CodingKeys: String, CodingKey {
        case enabled
    }
}
