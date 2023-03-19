//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import SwiftUI
import Drops

public class ToastrService {
    public static let shared = ToastrService()
    private init() { }

    public func showSuccess(_ title: String, imageSystemName: String, subtitle: String? = nil) {
        let image = self.createImage(systemName: imageSystemName, color: UIColor(Color.accentColor))
        self.showSuccess(title, image: image, subtitle: subtitle)
    }
    
    public func showSuccess(_ title: String, imageName: String, subtitle: String? = nil) {
        let image = self.createImage(name: imageName, color: UIColor(Color.accentColor))
        self.showSuccess(title, image: image, subtitle: subtitle)
    }
    
    private func showSuccess(_ title: String, image: UIImage?, subtitle: String? = nil) {
        let drop = Drop(
            title: NSLocalizedString(title, comment: "Success displayed to the user."),
            subtitle: subtitle,
            subtitleNumberOfLines: 2,
            icon: image,
            action: .init {
                Drops.hideCurrent()
            },
            position: .top,
            duration: 3.0,
            accessibility: ""
        )
        
        Drops.show(drop)
    }
    
    public func showError(title: String = "global.error.unexpected", imageSystemName: String = "ant.circle.fill", subtitle: String? = nil) {
        let image = self.createImage(systemName: imageSystemName, color: UIColor(Color.accentColor))
        self.showError(title: title, image: image, subtitle: subtitle)
    }
    
    public func showError(title: String = "global.error.unexpected", imageName: String, subtitle: String? = nil) {
        let image = self.createImage(name: imageName, color: UIColor(Color.accentColor))
        self.showError(title: title, image: image, subtitle: subtitle)
    }
    
    private func showError(title: String = "global.error.unexpected", image: UIImage?, subtitle: String? = nil) {
        let drop = Drop(
            title: NSLocalizedString(title, comment: "Error displayed to the user."),
            subtitle: subtitle,
            subtitleNumberOfLines: 2,
            icon: image,
            action: .init {
                Drops.hideCurrent()
            },
            position: .top,
            duration: 3.0,
            accessibility: ""
        )
        
        Drops.show(drop)
    }
    
    private func createImage(name: String, color: UIColor) -> UIImage? {
        guard let uiImage = UIImage(named: name) else {
            return nil
        }
            
        return uiImage.withTintColor(color, renderingMode: .alwaysOriginal)
    }
    
    private func createImage(systemName: String, color: UIColor) -> UIImage? {
        guard let uiImage = UIImage(systemName: systemName) else {
            return nil
        }
            
        return uiImage.withTintColor(color, renderingMode: .alwaysOriginal)
    }
}
