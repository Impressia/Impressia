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
            if let cachedAvatar {
                Image(uiImage: cachedAvatar)
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48.0, height: 48.0)
            }
            else {
                AsyncImage(url: accountAvatar) { image in
                    image
                        .resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .clipShape(Circle())
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.mainTextColor)
                }
                .frame(width: 48.0, height: 48.0)
            }
            
            VStack (alignment: .leading) {
                Text(accountDisplayName ?? accountUsername)
                    .foregroundColor(Color.mainTextColor)
                Text("@\(accountUsername)")
                    .foregroundColor(Color.lightGrayColor)
                    .font(.footnote)
            }
            .padding(.leading, 8)
        }
    }
}

struct UsernameRow_Previews: PreviewProvider {
    static var previews: some View {
        UsernameRow(accountUsername: "")
    }
}
