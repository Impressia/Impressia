//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import NukeUI

struct UsernameRow: View {
    @State public var accountAvatar: URL?
    @State public var accountDisplayName: String?
    @State public var accountUsername: String
    @State public var cachedAvatar: UIImage?

    var body: some View {
        HStack (alignment: .center) {
            UserAvatar(accountAvatar: accountAvatar,
                       cachedAvatar: cachedAvatar,
                       width: 48,
                       height: 48)
            
            VStack (alignment: .leading) {
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

struct UsernameRow_Previews: PreviewProvider {
    static var previews: some View {
        UsernameRow(accountDisplayName: "John Doe", accountUsername: "johndoe@mastodon.xx")
            .previewLayout(.fixed(width: 320, height: 64))
    }
}
