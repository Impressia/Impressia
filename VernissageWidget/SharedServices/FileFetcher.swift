//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import UIKit

public class FileFetcher {
    public static let shared = FileFetcher()
    private init() { }

    private let maxImageSize = 1000.0

    public func getImage(url: URL?) async -> UIImage? {
        guard let url else {
            return nil
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
                return nil
            }

            guard let uiImage = UIImage(data: data) else {
                return nil
            }

            if uiImage.size.width < self.maxImageSize && uiImage.size.height < self.maxImageSize {
                return uiImage
            }

            if uiImage.size.width > uiImage.size.height {
                return uiImage.resized(toWidth: self.maxImageSize)
            } else {
                return uiImage.resized(toHeight: self.maxImageSize)
            }
        } catch {
            return nil
        }
    }
}
