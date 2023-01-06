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
    
    func downloadImage(for accountId: String?, avatarUrl: URL?) async {
        guard let accountId, let avatarUrl else {
            return
        }
        
        do {
            let avatarData = try await RemoteFileService.shared.fetchData(url: avatarUrl)
            if let avatarData {
                CacheAvatarService.shared.addImage(for: accountId, data: avatarData)
            }
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    func getImage(for id: String) -> UIImage? {
        return self.cache[id]
    }
}
