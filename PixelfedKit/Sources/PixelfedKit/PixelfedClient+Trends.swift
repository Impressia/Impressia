//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public extension PixelfedClientAuthenticated {

    func statusesTrends(range: Pixelfed.Trends.TrendRange) async throws -> [Status] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Trends.statuses(range, nil, nil),
            withBearerToken: token
        )
        
        return try await downloadJson([Status].self, request: request)
    }
    
    func tagsTrends() async throws -> [TagTrend] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Trends.tags(nil, nil, nil),
            withBearerToken: token
        )
        
        return try await downloadJson([TagTrend].self, request: request)
    }
    
    func accountsTrends() async throws -> [Account] {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Trends.accounts(nil, nil, nil),
            withBearerToken: token
        )
        
        return try await downloadJson([Account].self, request: request)
    }
}
