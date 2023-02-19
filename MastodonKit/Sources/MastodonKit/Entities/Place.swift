//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

/// Location where image has been taken.
/// Entity specific for Pixelfed.
public struct Place: Codable {
    
    /// Id of the entity.
    public let id: Int
    
    /// City where picture has been taken.
    public let slug: String?
    
    /// City where picture has been taken.
    public let name: String?
    
    /// Country where picture has been taken.
    public let country: String?
}
