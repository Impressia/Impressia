//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public enum NetworkError: Error {
    case notSuccessResponse(URLResponse)
    case unknownError
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notSuccessResponse(let response):
            let statusCode = response.statusCode()

            let localizedString = NSLocalizedString("global.error.notSuccessResponse",
                                                    bundle: Bundle.module,
                                                    comment: "It's error returned from remote server. Request URL: '\(response.url?.string ?? "unknown")'.")

            return String(format: localizedString, statusCode?.localizedDescription ?? "unknown")
        case .unknownError:
            return NSLocalizedString("global.error.unknownError",
                                     bundle: Bundle.module,
                                     comment: "Response doesn't contains any information about request status.")
        }
    }
}
