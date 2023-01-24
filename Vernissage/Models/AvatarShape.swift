//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import SwiftUI

public enum AvatarShape: Int {
    case circle = 1
    case roundedRectangle = 2
    
    func shape() -> some Shape {
        switch self {
        case .circle:
            return AnyShape(Circle())
        case .roundedRectangle:
            return AnyShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}
