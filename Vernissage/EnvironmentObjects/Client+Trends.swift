//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import PixelfedKit

/// Pixelfed 'Trends'.
extension Client {
    public class Trends: BaseClient {
        public func statuses(range: Pixelfed.Trends.TrendRange) async throws -> [Status] {
            return try await pixelfedClient.statusesTrends(range: range)
        }
        
        public func tags() async throws -> [TagTrend] {
            return try await pixelfedClient.tagsTrends()
        }
        
        public func accounts() async throws -> [Account] {
            return try await pixelfedClient.accountsTrends()
        }
    }
}
