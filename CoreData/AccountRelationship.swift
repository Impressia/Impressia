//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData

@Model final public class AccountRelationship {
    public var accountId: String
    public var boostedStatusesMuted: Bool
    public var pixelfedAccount: AccountData?
    
    init(accountId: String, boostedStatusesMuted: Bool, pixelfedAccount: AccountData? = nil) {
        self.accountId = accountId
        self.boostedStatusesMuted = boostedStatusesMuted
        self.pixelfedAccount = pixelfedAccount
    }
}

extension AccountRelationship: Identifiable {
}
