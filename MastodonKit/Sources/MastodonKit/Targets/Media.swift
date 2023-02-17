//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

fileprivate let multipartBoundary = UUID().uuidString

extension Mastodon {
    public enum Media {
        case upload(Data, String, String, String?, CGPoint?)
    }
}

extension Mastodon.Media: TargetType {
    fileprivate var apiPath: String { return "/api/v2/media" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .upload:
            return "\(apiPath)"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .upload:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        switch self {
        case .upload:
            return nil
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .upload:
            return ["content-type": "multipart/form-data; boundary=\(multipartBoundary)"]
        }
    }
    
    public var httpBody: Data? {
        switch self {
        case .upload(let data, let fileName, let mimeType, let description, let focus):
            let formDataBuilder = MultipartFormData(boundary: multipartBoundary)
            formDataBuilder.addDataField(named: "file", fileName: fileName, data: data, mimeType: mimeType)

            if let description {
                formDataBuilder.addTextField(named: "description", value: description)
            }

            if let focus {
                formDataBuilder.addTextField(named: "focus", value: "(\(focus.x), \(focus.y)")
            }

            return formDataBuilder.build()
        }
    }
}
