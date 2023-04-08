//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI
import PhotosUI

public extension PhotosPickerItem {
    func createImageFileTranseferable() async throws -> ImageFileTranseferable? {
        return try await withCheckedThrowingContinuation { continuation in
            _ = self.loadTransferable(type: ImageFileTranseferable.self) { result in
                switch result {
                case let .success(success):
                  continuation.resume(with: .success(success))
                case .failure:
                  continuation.resume(with: .success(nil))
                }
            }
        }
    }
}
