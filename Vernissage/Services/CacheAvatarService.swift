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
    
    private var memoryChartData = MemoryCache<String, UIImage>(entryLifetime: 5 * 60)
        
    func addImage(for id: String, data: Data) {
        if let uiImage = UIImage(data: data) {
            self.memoryChartData[id] = uiImage
        }
    }
    
    func downloadImage(for accountId: String?, avatarUrl: URL?) async {
        guard let accountId, let avatarUrl else {
            return
        }
        
        if memoryChartData[accountId] != nil {
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
        return self.memoryChartData[id]
    }
}
