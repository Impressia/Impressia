//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation
import SwiftUI

public class CacheAvatarService {
    public static let shared = CacheAvatarService()
    private init() { }
    
    private var cache: Dictionary<String, UIImage> = [:]
    
    func addImage(for id: String, data: Data) {
        if let uiImage = UIImage(data: data) {
            self.cache[id] = uiImage
        }
    }
    
    func getImage(for id: String) -> UIImage? {
        return self.cache[id]
    }
}
