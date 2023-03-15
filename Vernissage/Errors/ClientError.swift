//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public enum ClientError: Error {
    case cannotRetrieveStatus
}

extension ClientError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cannotRetrieveStatus:
            return NSLocalizedString("global.error.errorDuringDownloadStatus", comment: "Status cannot be downloaded from server.")
        }
    }
}
