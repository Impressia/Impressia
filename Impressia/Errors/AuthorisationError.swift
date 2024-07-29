//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public enum AuthorisationError: Error {
    case badServerUrl
    case accessTokenNotFound
}

extension AuthorisationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badServerUrl:
            return NSLocalizedString("global.error.badUrlServer", comment: "User enter bad URL to server.")
        case .accessTokenNotFound:
            return NSLocalizedString("global.error.accessTokenNotFound", comment: "Access token is not saved in account model.")
        }
    }
}
