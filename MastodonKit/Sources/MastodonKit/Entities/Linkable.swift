//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

/// Some of endpoint returns JSON data and additional information in header, like link for paging functionality.
public struct Linkable<T> where T: Codable {
    
    /// Data retunred in HTTP reponse body (mostly JSON data/entities).
    public let data: T
    
    /// Link returned in the HTTP header.
    public let link: Link?
    
    public init(data: T, link: Link? = nil) where T: Codable {
        self.data = data
        self.link = link
    }
}
