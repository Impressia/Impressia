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
        let drop = Drop(
            title: title,
            subtitle: subtitle,
            subtitleNumberOfLines: 2,
            icon: self.createImage(systemName: imageSystemName, color: UIColor(Color.accentColor)),
            action: .init {
                Drops.hideCurrent()
            },
            position: .top,
            duration: 3.0,
            accessibility: ""
        )
        
        Drops.show(drop)
    }
    
    public func showError(title: String = "Unexpected error", imageSystemName: String = "ant.circle.fill", subtitle: String? = nil) {
        let drop = Drop(
            title: title,
            subtitle: subtitle,
            subtitleNumberOfLines: 2,
            icon: self.createImage(systemName: imageSystemName, color: UIColor(Color.red)),
            action: .init {
                Drops.hideCurrent()
            },
            position: .top,
            duration: 3.0,
            accessibility: ""
        )
        
        Drops.show(drop)
    }
    
    private func createImage(systemName: String, color: UIColor) -> UIImage? {
        guard let uiImage = UIImage(systemName: systemName) else {
            return nil
        }
            
        return uiImage.withTintColor(color, renderingMode: .alwaysOriginal)
    }
}
