//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
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
