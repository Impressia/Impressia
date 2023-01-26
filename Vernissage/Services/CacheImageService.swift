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
    
    private var memoryCacheData = MemoryCache<URL, Image>(entryLifetime: 600)
        
    func addImage(for url: URL, data: Data) {
        if let uiImage = UIImage(data: data) {
            self.memoryCacheData[url] = Image(uiImage: uiImage)
        }
    }

    func addImage(for url: URL, image: Image) {
        self.memoryCacheData[url] = image
    }

    func downloadImage(url: URL?) async {
        guard let url else {
            return
        }
        
        if memoryCacheData[url] != nil {
            return
        }
        
        do {
            let imageData = try await RemoteFileService.shared.fetchData(url: url)
            if let imageData {
                CacheImageService.shared.addImage(for: url, data: imageData)
            }
        } catch {
            ErrorService.shared.handle(error, message: "Downloading image into cache failed.")
        }
    }
    
    func getImage(for url: URL) -> Image? {
        return self.memoryCacheData[url]
    }
}
