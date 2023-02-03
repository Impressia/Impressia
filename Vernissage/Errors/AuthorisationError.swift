//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
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
            return NSLocalizedString("Bad url to server.", comment: "User enter bad URL to server.")
        case .accessTokenNotFound:
            return NSLocalizedString("Acess token not found.", comment: "Access token is not saved in account model.")
        }
    }
}
