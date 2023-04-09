//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Markers {
        public enum Timeline: String, Encodable {
            case home
            case notifications
        }

        case set([Timeline: EntityId])
        case read(Set<Timeline>)
    }
}

extension Pixelfed.Markers: TargetType {
    private var apiPath: String { return "/api/v1/markers" }

    public var path: String {
        return apiPath
    }

    public var method: Method {
        switch self {
        case .set:
            return .post
        case .read:
            return .get
        }
    }

    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }

    public var queryItems: [(String, String)]? {
        switch self {
        case .set:
            return nil
        case .read(let markers):
            return Array(markers)
                .map { ("timeline[]", $0.rawValue) }
        }
    }

    public var httpBody: Data? {
        switch self {
        case .set(let markers):
            let dict = Dictionary(uniqueKeysWithValues: markers.map { ($0.rawValue, ["last_read_id": $1]) })
            let data = try? JSONEncoder().encode(dict)
            return data
        case .read:
            return nil
        }
    }

}
