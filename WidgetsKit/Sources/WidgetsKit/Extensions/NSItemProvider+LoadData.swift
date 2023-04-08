//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension NSItemProvider {
    func loadData() async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            _ = self.loadDataRepresentation(for: .image) { (data, error) in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: data)
                }
            }
        }
    }
}
