//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
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

            return NSLocalizedString("Server response: '\(statusCode?.localizedDescription ?? "unknown")'.", comment: "It's error returned from remote server. Request URL: '\(response.url?.string ?? "unknown")'.")
        case .unknownError:
            return NSLocalizedString("Unkonwn network error.", comment: "Response doesn't contains any information about request status.")
        }
    }
}
