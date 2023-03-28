//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
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
            return NSLocalizedString("global.error.errorDuringPurchaseVerification", comment: "Something went wrong during purchase verification.")
        case .system(let error):
            return error.localizedDescription
        }
    }
}
