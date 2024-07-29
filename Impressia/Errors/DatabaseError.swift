//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public enum DatabaseError: Error {
    case cannotDownloadAccount
}

extension DatabaseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cannotDownloadAccount:
            return NSLocalizedString("global.error.errorDuringUserRead", comment: "User acount cannot be downloaded from Core Data.")
        }
    }
}
