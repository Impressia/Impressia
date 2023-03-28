//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Infor about image stored in metadata.
public struct ImageInfo: Codable {
    
    /// Width of the image.
    public let width: Int
    
    /// Height of the image.
    public let height: Int
    
    /// Size of the image.
    public let size: String
    
    /// Aspect ratio of the image.
    public let aspect: Double

    private enum CodingKeys: String, CodingKey {
        case width
        case height
        case size
        case aspect
    }
}
