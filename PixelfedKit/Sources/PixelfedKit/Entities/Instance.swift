//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the software instance of Pixelfed running on this domain.
public struct Instance: Codable {
    /// The domain name of the instance.
    public let uri: String
        
    /// The version of Pixelfed installed on the instance.
    public let version: String
    
    /// The title of the website.
    public let title: String?
    
    /// The URL for the source code of the software running on this instance, in keeping with AGPL license requirements.
    public let sourceUrl: URL?
    
    /// A short, plain-text description defined by the admin.
    public let shortDescription: String?
    
    /// A  plain-text description defined by the admin.
    public let description: Html?
    
    /// The URL for the thumbnail image.
    public let thumbnail: URL?
    
    /// Primary languages of the website and its staff. Array of String (ISO 639-1 two-letter code).
    public let languages: [String]?
    
    /// Configured values and limits for this website.
    public let configuration: Configuration?
        
    /// If registration new accounts on server is enabled
    public let registrations: Bool
    
    /// If approval for registration account is mandatory.
    public let approvalRequired: Bool
    
    /// An itemized list of rules for this website.
    public let rules: [Rule]?
    
    /// Main contact email.
    public let email: String?
    
    /// Statistics about the instance.
    public let stats: Stats?
    
    /// Contact account.
    public let contactAccount: Account?
    
    enum CodingKeys: String, CodingKey {
        case uri
        case title
        case version
        case sourceUrl = "source_url"
        case shortDescription = "short_description"
        case description
        case thumbnail
        case languages
        case configuration
        case rules
        case email
        case registrations
        case approvalRequired = "approval_required"
        case stats
        case contactAccount = "contact_account"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uri = try container.decode(String.self, forKey: .uri)
        self.version = try container.decode(String.self, forKey: .version)
        
        self.title = try? container.decodeIfPresent(String.self, forKey: .title)
        self.sourceUrl = try? container.decodeIfPresent(URL.self, forKey: .sourceUrl)
        self.shortDescription = try? container.decodeIfPresent(String.self, forKey: .shortDescription)
        self.description = try? container.decodeIfPresent(Html.self, forKey: .description)
        self.thumbnail = try? container.decodeIfPresent(URL.self, forKey: .thumbnail)
        self.languages = try? container.decodeIfPresent([String].self, forKey: .languages)
        self.configuration = try? container.decodeIfPresent(Configuration.self, forKey: .configuration)
        self.rules = try? container.decodeIfPresent([Rule].self, forKey: .rules)
        self.email = try? container.decodeIfPresent(String.self, forKey: .email)
        self.registrations = (try? container.decodeIfPresent(Bool.self, forKey: .registrations)) ?? false
        self.approvalRequired = (try? container.decodeIfPresent(Bool.self, forKey: .approvalRequired)) ?? false
        self.stats = try? container.decodeIfPresent(Stats.self, forKey: .stats)
        self.contactAccount = try? container.decodeIfPresent(Account.self, forKey: .contactAccount)
    }
}
