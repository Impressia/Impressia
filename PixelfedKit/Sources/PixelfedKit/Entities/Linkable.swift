//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Some of endpoint returns JSON data and additional information in header, like link for paging functionality.
public struct Linkable<T> : Codable where T: Codable {

    /// Data retunred in HTTP reponse body (mostly JSON data/entities).
    public let data: T

    /// Link returned in the HTTP header.
    public let link: Link?

    public init(data: T, link: Link? = nil) where T: Codable {
        self.data = data
        self.link = link
    }
}

public extension Linkable<[Status]> {
    func getMinId() -> String? {
        if let link = self.link {
            return link.minId
        }
        
        if let firstItemId = self.data.first?.id {
            return firstItemId
        }
        
        return nil
    }
    
    func getMaxId() -> String? {
        if let link = self.link {
            return link.maxId
        }
        
        if let lastItemId = self.data.last?.id {
            return lastItemId
        }
        
        return nil
    }
}
