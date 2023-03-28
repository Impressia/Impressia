//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Tags {
        case tag(Hashtag)
        case follow(Hashtag)
        case unfollow(Hashtag)
    }
}

extension Pixelfed.Tags: TargetType {
    private var apiPath: String { return "/api/v1/tags" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .tag(let hashtag):
            return "\(apiPath)/\(hashtag)"
        case .follow(let hashtag):
            return "\(apiPath)/\(hashtag)/follow"
        case .unfollow(let hashtag):
            return "\(apiPath)/\(hashtag)/unfollow"
        }
    }
    
    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .tag:
            return .get
        case .follow, .unfollow:
            return .post
        }
    }
    
    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {        
        return nil
    }
    
    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }
    
    public var httpBody: Data? {
        nil
    }
}
