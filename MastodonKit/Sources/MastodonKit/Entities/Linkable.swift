//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public struct Linkable<T> where T: Codable {
    public let data: T
    public let link: Link?
    
    public init(data: T, link: Link? = nil) where T: Codable {
        self.data = data
        self.link = link
    }
}
