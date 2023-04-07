//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import NukeUI

public struct UsernameRow: View {
    @State public var accountId: String
    @State public var accountAvatar: URL?
    @State public var accountDisplayName: String?
    @State public var accountUsername: String
    @State public var size: UserAvatar.Size?

    public init(accountId: String,
                accountAvatar: URL? = nil,
                accountDisplayName: String? = nil,
                accountUsername: String,
                size: UserAvatar.Size? = nil) {
        _accountId = State(initialValue: accountId)
        _accountAvatar = State(initialValue: accountAvatar)
        _accountDisplayName = State(initialValue: accountDisplayName)
        _accountUsername = State(initialValue: accountUsername)
        _size = State(initialValue: size)
    }

    public var body: some View {
        HStack(alignment: .center) {
            UserAvatar(accountAvatar: accountAvatar, size: size ?? .list)

            VStack(alignment: .leading) {
                Text(accountDisplayName ?? accountUsername)
                    .foregroundColor(.mainTextColor)
                Text("@\(accountUsername)")
                    .foregroundColor(.lightGrayColor)
                    .font(.footnote)
            }
            .padding(.leading, 8)
        }
    }
}
