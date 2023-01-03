//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct InteractionRow: View {
    @State public var statusData: StatusData

    var body: some View {
        HStack (alignment: .top) {
            Tag {
                // Favorite
            } content: {
                HStack {
                    Image(systemName: statusData.favourited ? "heart.fill" : "heart")
                    Text("\(statusData.favouritesCount) likes")
                }
            }
            
            Tag {
                // Reboost
            } content: {
                HStack {
                    Image(systemName: statusData.reblogged ? "arrowshape.turn.up.forward.fill" : "arrowshape.turn.up.forward")
                    Text("\(statusData.reblogsCount) boosts")
                }
            }
            
            Spacer()
            
            Tag {
                // Bookmark
            } content: {
                Image(systemName: statusData.bookmarked ? "bookmark.fill" : "bookmark")
            }
        }
        .font(.subheadline)
        .foregroundColor(Color("mainTextColor"))
    }
}

struct InteractionRow_Previews: PreviewProvider {
    static var previews: some View {
        InteractionRow(statusData: StatusData())
    }
}
