//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import MastodonSwift

public class AccountService {
    public static let shared = AccountService()
    
    public func getAccount(withId accountId: String, and accountData: AccountData?) async throws -> Account? {
        guard let accessToken = accountData?.accessToken, let serverUrl = accountData?.serverUrl else {
            return nil
        }

        let client = MastodonClient(baseURL: serverUrl).getAuthenticated(token: accessToken)
        return try await client.getAccount(for: accountId)
    }
}
