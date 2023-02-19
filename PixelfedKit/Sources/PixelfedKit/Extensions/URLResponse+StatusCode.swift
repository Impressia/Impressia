//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public extension URLResponse {
    func statusCode() -> HTTPStatusCode? {
        let statusCode = (self as? HTTPURLResponse)?.status
        return statusCode
    }
}
