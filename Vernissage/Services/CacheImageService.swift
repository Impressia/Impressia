//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation
import SwiftUI

public class CacheImageService {
    public static let shared = CacheImageService()
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

    func downloadImage(for accountId: String?, url: URL?) async {
        guard let accountId, let url else {
            return
        }
        
        if memoryChartData[accountId] != nil {
            return
        }
        
        do {
            let imageData = try await RemoteFileService.shared.fetchData(url: url)
            if let imageData {
                CacheImageService.shared.addImage(for: accountId, data: imageData)
            }
        } catch {
            ErrorService.shared.handle(error, message: "Downloading image into cache failed.")
        }
    }
    
    func getImage(for id: String) -> Image? {
        return self.memoryChartData[id]
    }
}
