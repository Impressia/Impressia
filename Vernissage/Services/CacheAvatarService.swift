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
    
    private var memoryChartData = MemoryCache<String, Image>(entryLifetime: 5 * 60)
        
    func addImage(for id: String, data: Data) {
        if let uiImage = UIImage(data: data) {
            self.memoryChartData[id] = Image(uiImage: uiImage)
        }
    }

    func addImage(for id: String, image: Image) {
        self.memoryChartData[id] = image
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
            ErrorService.shared.handle(error, message: "Downloading avatar into cache failed.")
        }
    }
    
    func getImage(for id: String) -> Image? {
        return self.memoryChartData[id]
    }
}
