//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation
import SwiftUI

extension UIImage {
    func roundedAvatar(avatarShape: AvatarShape) -> UIImage {
        let imageView: UIImageView = UIImageView(image: self)
        let layer = imageView.layer
        layer.masksToBounds = true
        
        switch avatarShape {
        case .circle:
            layer.cornerRadius = imageView.frame.width / 2
        case .roundedRectangle:
            layer.cornerRadius = imageView.frame.width / 6
        }
        
        UIGraphicsBeginImageContext(imageView.bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return roundedImage!
    }
}
