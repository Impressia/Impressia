//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonSwift

extension MastodonClientAuthenticated {
    func getContext(for statusId: String) async throws -> Context {
        let request = try Self.request(
            for: baseURL,
            target: Mastodon.Statuses.context(statusId),
            withBearerToken: token
        )
        
        let (data, response) = try await urlSession.data(for: request)
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
        
        return try JSONDecoder().decode(Context.self, from: data)
    }
}
