//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftData

@Model final public class ViewedStatus {
    @Attribute(.unique) public var id: String
    public var reblogId: String?
    public var date: Date
    public var pixelfedAccount: AccountData?
    
    init(id: String, reblogId: String? = nil, date: Date, pixelfedAccount: AccountData? = nil) {
        self.id = id
        self.reblogId = reblogId
        self.date = date
        self.pixelfedAccount = pixelfedAccount
    }
}

extension ViewedStatus: Identifiable {
}

