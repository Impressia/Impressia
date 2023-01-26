//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

/// Represents an application that interfaces with the REST API to access accounts or post statuses.
/// Base object is used in statuses etc.
public class BaseApplication: Codable {
    
    /// The name of your application.
    public let name: String
    
    // The website associated with your application.
    public let website: URL?
    
    init(name: String, website: URL?) {
        self.name = name
        self.website = website
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case website
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: .name)
        self.website = try? container.decodeIfPresent(URL.self, forKey: .website)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        
        if let website {
            try container.encode(website, forKey: .website)
        }
    }
}
