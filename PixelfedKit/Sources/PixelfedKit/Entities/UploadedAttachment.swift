//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents a file or media attachment that can be added to a status.
public class UploadedAttachment: Codable {

    public enum UploadedAttachmentType: String, Codable {
        case unknown
        case image
        case gifv
        case video
        case audio
    }

    /// The ID of the attachment in the database.
    public let id: String

    /// The type of the attachment.
    public let type: UploadedAttachmentType

    /// The location of the original full-size attachment.
    public let url: URL?

    /// The location of a scaled-down preview of the attachment.
    public let previewUrl: URL?

    /// The location of the full-size original attachment on the remote website.
    public let remoteUrl: URL?

    /// Alternate text that describes what is in the media attachment, to be used for the visually impaired or when media attachments do not load.
    public let description: String?

    /// A hash computed by the [BlurHash](https://github.com/woltapp/blurhash) algorithm, for generating colorful preview thumbnails when media has not been downloaded yet.
    public let blurhash: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case url
        case previewUrl = "preview_url"
        case remoteUrl = "remote_url"
        case description
        case blurhash
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(EntityId.self, forKey: .id)
        self.type = try container.decode(UploadedAttachmentType.self, forKey: .type)
        self.url = try? container.decode(URL.self, forKey: .url)
        self.previewUrl = try? container.decode(URL.self, forKey: .previewUrl)
        self.remoteUrl = try? container.decode(URL.self, forKey: .remoteUrl)
        self.description = try? container.decode(String.self, forKey: .description)
        self.blurhash = try? container.decode(String.self, forKey: .blurhash)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)

        if let url {
            try container.encode(url, forKey: .url)
        }

        if let previewUrl {
            try container.encode(previewUrl, forKey: .previewUrl)
        }

        if let remoteUrl {
            try container.encode(remoteUrl, forKey: .remoteUrl)
        }

        if let description {
            try container.encode(description, forKey: .description)
        }

        if let blurhash {
            try container.encode(blurhash, forKey: .blurhash)
        }
    }
}
