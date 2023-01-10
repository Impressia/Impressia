import Foundation

extension Mastodon {
    public enum Account {
        case account(AccountId)
        case verifyCredentials
        case followers(AccountId, MaxId?, SinceId?, MinId?, Limit?, Page?)
        case following(AccountId, MaxId?, SinceId?, MinId?, Limit?, Page?)
        case statuses(AccountId, Bool, Bool, MaxId?, SinceId?, MinId?, Limit?)
        case follow(AccountId)
        case unfollow(AccountId)
        case block(AccountId)
        case unblock(AccountId)
        case mute(AccountId)
        case unmute(AccountId)
        case relationships([AccountId])
        case search(SearchQuery, Int)
    }
}

extension Mastodon.Account: TargetType {
    fileprivate var apiPath: String { return "/api/v1/accounts" }

    public var path: String {
        switch self {
        case .account(let id):
            return "\(apiPath)/\(id)"
        case .verifyCredentials:
            return "\(apiPath)/verify_credentials"
        case .followers(let id, _, _, _, _, _):
            return "\(apiPath)/\(id)/followers"
        case .following(let id, _, _, _, _, _):
            return "\(apiPath)/\(id)/following"
        case .statuses(let id, _, _, _, _, _, _):
            return "\(apiPath)/\(id)/statuses"
        case .follow(let id):
            return "\(apiPath)/\(id)/follow"
        case .unfollow(let id):
            return "\(apiPath)/\(id)/unfollow"
        case .block(let id):
            return "\(apiPath)/\(id)/block"
        case .unblock(let id):
            return "\(apiPath)/\(id)/unblock"
        case .mute(let id):
            return "\(apiPath)/\(id)/mute"
        case .unmute(let id):
            return "\(apiPath)/\(id)/unmute"
        case .relationships(_):
            return "\(apiPath)/relationships"
        case .search(_, _):
            return "\(apiPath)/search"
        }
    }
    
    public var method: Method {
        switch self {
        case .follow(_), .unfollow(_), .block(_), .unblock(_), .mute(_), .unmute(_):
            return .post
        default:
            return .get
        }
    }
        
    public var queryItems: [(String, String)]? {
        var params: [(String, String)] = []

        var maxId: MaxId? = nil
        var sinceId: SinceId? = nil
        var minId: MinId? = nil
        var limit: Limit? = nil
        var page: Page? = nil

        switch self {
        case .statuses(_, let onlyMedia, let excludeReplies, let _maxId, let _sinceId, let _minId, let _limit):
            params.append(contentsOf: [
                ("only_media", onlyMedia.asString),
                ("exclude_replies", excludeReplies.asString)
            ])
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
        case .relationships(let id):
            return id.map({ id in
                    ("id[]", id)
                })
        case .search(let query, let limit):
            return [
                ("q", query),
                ("limit", limit.asString)
            ]
        case .following(_, let _maxId, let _sinceId, let _minId, let _limit, let _page):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
            page = _page
        case .followers(_, let _maxId, let _sinceId, let _minId, let _limit, let _page):
            maxId = _maxId
            sinceId = _sinceId
            minId = _minId
            limit = _limit
            page = _page
        default:
            return nil
        }
        
        if let maxId {
            params.append(("max_id",  maxId))
        }
        if let sinceId {
            params.append(("since_id", sinceId))
        }
        if let minId {
            params.append(("min_id", minId))
        }
        if let limit {
            params.append(("limit", "\(limit)"))
        }
        if let page {
            params.append(("page", "\(page)"))
        }
        
        return params
    }
    
    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }
    
    public var httpBody: Data? {
        nil
    }
}
