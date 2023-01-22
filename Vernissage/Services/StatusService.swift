//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

public class StatusService {
    public static let shared = StatusService()
    private init() { }
    
    public func getStatus(withId statusId: String, and accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }

        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.read(statusId: statusId)
    }
    
    func favourite(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.favourite(statusId: statusId)
    }
    
    func unfavourite(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unfavourite(statusId: statusId)
    }
    
    func boost(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.boost(statusId: statusId)
    }
    
    func unboost(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unboost(statusId: statusId)
    }
    
    func bookmark(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.bookmark(statusId: statusId)
    }
    
    func unbookmark(statusId: String, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.unbookmark(statusId: statusId)
    }
    
    func new(status: Mastodon.Statuses.Components, accountData: AccountData?) async throws -> Status? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.new(statusComponents: status)
    }
    
    func getComments(for statusId: String, and accountData: AccountData) async throws -> [CommentViewModel] {
        var commentViewModels: [CommentViewModel] = []
        
        let client = MastodonClient(baseURL: accountData.serverUrl).getAuthenticated(token: accountData.accessToken ?? String.empty())
        try await self.getCommentDescendants(for: statusId, client: client, showDivider: true, to: &commentViewModels)
        
        return commentViewModels
    }
    
    public func favouritedBy(statusId: String, andContext accountData: AccountData?, page: Int) async throws -> [Account] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.favouritedBy(for: statusId, page: page)
    }
    
    public func rebloggedBy(statusId: String, andContext accountData: AccountData?, page: Int) async throws -> [Account] {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return []
        }
        
        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.rebloggedBy(for: statusId, page: page)
    }
    
    private func getCommentDescendants(for statusId: String, client: MastodonClientAuthenticated, showDivider: Bool, to commentViewModels: inout [CommentViewModel]) async throws {
        let context = try await client.getContext(for: statusId)
        
        let descendants = context.descendants.toStatusViewModel()
        for status in descendants {
            commentViewModels.append(CommentViewModel(status: status, showDivider: showDivider))
            
            if status.repliesCount > 0 {
                try await self.getCommentDescendants(for: status.id, client: client, showDivider: false, to: &commentViewModels)
            }
        }
    }
}
