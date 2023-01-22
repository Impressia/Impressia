//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the software instance of Mastodon running on this domain.
public struct Instance: Codable {
    /// The domain name of the instance.
    public let domain: String
        
    /// The title of the website.
    public let title: String?
    
    /// The version of Mastodon installed on the instance.
    public let version: String
    
    /// The URL for the source code of the software running on this instance, in keeping with AGPL license requirements.
    public let sourceUrl: URL?
    
    /// A short, plain-text description defined by the admin.
    public let description: String?
    
    /// Usage data for this instance.
    public let usage: Usage?
    
    /// The URL for the thumbnail image.
    public let thumbnail: Thumbnail?
    
    /// Primary languages of the website and its staff. Array of String (ISO 639-1 two-letter code).
    public let languages: [String]?
    
    /// Configured values and limits for this website.
    public let configuration: Configuration?
    
    /// Information about registering for this website.
    public let registrations: Registration?
    
    /// Hints related to contacting a representative of the website.
    public let contact: Contact?
    
    /// An itemized list of rules for this website.
    public let rules: [Rule]?
    
    enum CodingKeys: String, CodingKey {
        case domain
        case title
        case version
        case sourceUrl = "source_url"
        case description
        case usage
        case thumbnail
        case languages
        case configuration
        case registrations
        case contact
        case rules
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.domain = try container.decode(String.self, forKey: .domain)
        self.title = try? container.decodeIfPresent(String.self, forKey: .title)
        self.version = try container.decode(String.self, forKey: .version)
        self.sourceUrl = try? container.decodeIfPresent(URL.self, forKey: .sourceUrl)
        self.description = try? container.decodeIfPresent(String.self, forKey: .description)
        self.usage = try? container.decodeIfPresent(Usage.self, forKey: .usage)
        self.thumbnail = try? container.decodeIfPresent(Thumbnail.self, forKey: .thumbnail)
        self.languages = try? container.decodeIfPresent([String].self, forKey: .languages)
        self.configuration = try? container.decodeIfPresent(Configuration.self, forKey: .configuration)
        self.registrations = try? container.decodeIfPresent(Registration.self, forKey: .registrations)
        self.contact = try? container.decodeIfPresent(Contact.self, forKey: .contact)
        self.rules = try? container.decodeIfPresent([Rule].self, forKey: .rules)
    }
}
