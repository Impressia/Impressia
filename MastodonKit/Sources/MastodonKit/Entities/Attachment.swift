import Foundation

public class Attachment: Codable {
    public enum AttachmentType: String, Codable {
        case unknown    = "unknown"
        case image      = "image"
        case gifv       = "gifv"
        case video      = "video"
        case audio      = "audio"
    }
    
    public let id: String
    public let type: AttachmentType
    public let url: URL
    public let previewUrl: URL?

    public let remoteUrl: URL?
    public let description: String?
    public let blurhash: String?
    public let meta: Metadata?

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case url
        case previewUrl = "preview_url"

        case remoteUrl = "remote_url"
        case description
        case blurhash
        case meta
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(StatusId.self, forKey: .id)
        self.type = try container.decode(AttachmentType.self, forKey: .type)
        self.url = try container.decode(URL.self, forKey: .url)
        self.previewUrl = try? container.decode(URL.self, forKey: .previewUrl)
        self.remoteUrl = try? container.decode(URL.self, forKey: .remoteUrl)
        self.description = try? container.decode(String.self, forKey: .description)
        self.blurhash = try? container.decode(String.self, forKey: .blurhash)
        
        switch self.type {
        case .image:
            self.meta = try? container.decode(ImageMetadata.self, forKey: .meta)
        default:
            self.meta = nil
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(url, forKey: .url)
        
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
        
        if let meta {
            try container.encode(meta, forKey: .meta)
        }
    }
}
