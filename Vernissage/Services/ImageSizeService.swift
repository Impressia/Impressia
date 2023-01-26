//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

public class ImageSizeService {
    public static let shared = ImageSizeService()
    private init() { }
    
    private var memoryCacheData = MemoryCache<URL, CGSize>(entryLifetime: 3600)
    
    func addImageSize(for url: URL, size: CGSize) {
        self.memoryCacheData[url] = size
    }
    
    func getImageSize(for url: URL) -> CGSize? {
        return self.memoryCacheData[url]
    }

    func calculateSize(for url: URL, width: Int32, height: Int32) -> CGSize {
        return calculateSize(for: url, width: Double(width), height: Double(height))
    }
    
    func calculateSize(for url: URL, width: Int, height: Int) -> CGSize {
        return calculateSize(for: url, width: Double(width), height: Double(height))
    }
    
    func calculateSize(for url: URL, width: Double, height: Double) -> CGSize {
        let divider = Double(width) / UIScreen.main.bounds.size.width
        let calculatedHeight = Double(height) / divider
        
        let size = CGSize(
            width: UIScreen.main.bounds.width,
            height: (calculatedHeight > 0 && calculatedHeight < .infinity) ? calculatedHeight : UIScreen.main.bounds.width
        )
        
        self.memoryCacheData.insert(size, forKey: url)
        return size
    }
}

