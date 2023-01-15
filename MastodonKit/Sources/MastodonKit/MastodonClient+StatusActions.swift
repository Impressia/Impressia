import Foundation

public extension MastodonClientAuthenticated {
    func read(statusId: StatusId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.status(statusId),
            withBearerToken: token)
        
        return try await downloadJson(Status.self, request: request)
    }

    func boost(statusId: StatusId) async throws -> Status {
        // TODO: Check whether the current user already boosted the status
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.reblog(statusId),
            withBearerToken: token
        )
                
        return try await downloadJson(Status.self, request: request)
    }
    
    func unboost(statusId: StatusId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.unreblog(statusId),
            withBearerToken: token
        )
        
        return try await downloadJson(Status.self, request: request)
    }

    func bookmark(statusId: StatusId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.bookmark(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unbookmark(statusId: StatusId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.unbookmark(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func favourite(statusId: StatusId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.favourite(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func unfavourite(statusId: StatusId) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.unfavourite(statusId),
            withBearerToken: token
        )

        return try await downloadJson(Status.self, request: request)
    }

    func new(statusComponents: Mastodon.Statuses.Components) async throws -> Status {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.new(statusComponents),
            withBearerToken: token)

        return try await downloadJson(Status.self, request: request)
    }
}
