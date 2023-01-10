//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public struct Place: Codable {
    public let id: Int32
    public let slug: String?
    public let name: String?
    public let country: String?
}
