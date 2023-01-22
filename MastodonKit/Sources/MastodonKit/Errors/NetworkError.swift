//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public enum NetworkError: Error {    
    case notSuccessResponse(URLResponse)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notSuccessResponse(let response):
            let statusCode = response.statusCode()
            return NSLocalizedString("Network request returned not success status code: '\(statusCode?.localizedDescription ?? "unknown")'. Request URL: '\(response.url?.string ?? "unknown")'.", comment: "It's error returned from remote server.")
        }
    }
}
