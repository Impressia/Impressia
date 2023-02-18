//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

fileprivate let multipartBoundary = UUID().uuidString

extension Mastodon {
    public enum Media {
        case upload(Data, String, String)
        case update(EntityId, String?, CGPoint?)
    }
}

extension Mastodon.Media: TargetType {
    struct Request: Encodable {
        let description: String?
        let focus: String?

        enum CodingKeys: String, CodingKey {
            case description
            case focus
        }
        
        func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<Mastodon.Media.Request.CodingKeys> = encoder.container(keyedBy: Mastodon.Media.Request.CodingKeys.self)
            try container.encode(self.description, forKey: Mastodon.Media.Request.CodingKeys.description)
            try container.encodeIfPresent(self.focus, forKey: Mastodon.Media.Request.CodingKeys.focus)
        }
    }
    
    
    fileprivate var apiPath: String { return "/api" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .upload:
            return "\(apiPath)/v2/media"
        case .update(let id, _, _):
            return "\(apiPath)/v1/media/\(id)"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .upload:
            return .post
        case .update(_, _, _):
            return .put
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        switch self {
        case .upload:
            return nil
        case .update(_, _, _):
            return nil
        }
    }
    
    public var headers: [String: String]? {
        switch self {
        case .upload:
            return ["content-type": "multipart/form-data; boundary=\(multipartBoundary)"]
        case .update(_, _, _):
            return nil
        }
    }
    
    public var httpBody: Data? {
        switch self {
        case .upload(let data, let fileName, let mimeType):
            let formDataBuilder = MultipartFormData(boundary: multipartBoundary)
            formDataBuilder.addDataField(named: "file", fileName: fileName, data: data, mimeType: mimeType)
            return formDataBuilder.build()
        case .update(_, let description, let focus):
            var focusString: String?
            
            if let focus {
                focusString = "(\(focus.x), \(focus.y))"
            }
            
            return try? JSONEncoder().encode(
                Request(description: description, focus: focusString)
            )
        }
    }
    
}
