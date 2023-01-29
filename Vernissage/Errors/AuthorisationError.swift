//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public enum AuthorisationError: Error {
    case badServerUrl
}

extension AuthorisationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badServerUrl:
            return NSLocalizedString("Bad url to server.", comment: "User enter bad URL to server.")
        }
    }
}
