//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation
import SwiftUI

public class CacheImageService {
    public static let shared = CacheImageService()
    private init() { }
    
    private var memoryCacheData = MemoryCache<URL, Image>(entryLifetime: 600)

    func download(url: URL?) async {
        guard let url else {
            return
        }
        
        if memoryCacheData[url] != nil {
            return
        }
        
        do {
            let imageData = try await RemoteFileService.shared.fetchData(url: url)
            if let imageData {
                self.add(data: imageData, for: url)
            }
        } catch {
            ErrorService.shared.handle(error, message: "Downloading image into cache failed.")
        }
    }
    
    func get(for url: URL) -> Image? {
        return self.memoryCacheData[url]
    }
    
    private func add(data: Data, for url: URL) {
        if let uiImage = UIImage(data: data) {
            self.memoryCacheData[url] = Image(uiImage: uiImage)
        }
    }
}
