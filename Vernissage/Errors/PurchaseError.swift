//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation

public enum PurchaseError: Error {
    case failedVerification
    case system(Error)
}

extension PurchaseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failedVerification:
            return NSLocalizedString("Purchase verification failed.", comment: "Something went wrong during purchase verification.")
        case .system(let error):
            return error.localizedDescription
        }
    }
}
