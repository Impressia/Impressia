//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public enum NetworkingError: String, Swift.Error {
    case cannotCreateUrlRequest
}

public enum Method: String {
    case delete = "DELETE", get = "GET", head = "HEAD", patch = "PATCH", post = "POST", put = "PUT"
}

public protocol TargetType {
    var path: String { get }
    var method: Method { get }
    var headers: [String: String]? { get }
    var queryItems: [(String, String)]? { get }
    var httpBody: Data? { get }
}

extension [String: String] {
    var contentTypeApplicationJson: [String: String] {
        var selfCopy = self
        selfCopy["content-type"] = "application/json"
        return selfCopy
    }
}
