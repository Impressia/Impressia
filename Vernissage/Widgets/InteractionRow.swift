//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct InteractionRow: View {
    @ObservedObject public var statusData: StatusData

    var body: some View {
        HStack (alignment: .top) {
            Button {
                // TODO: Reply.
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "message")
                    Text("\(statusData.repliesCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Button {
                // TODO: Reboost.
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: statusData.reblogged ? "paperplane.fill" : "paperplane")
                    Text("\(statusData.reblogsCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Button {
                // TODO: Favorite.
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: statusData.favourited ? "hand.thumbsup.fill" : "hand.thumbsup")
                    Text("\(statusData.favouritesCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Button {
                // TODO: Bookmark.
            } label: {
                Image(systemName: statusData.bookmarked ? "bookmark.fill" : "bookmark")
            }
            
            Spacer()
            
            Button {
                // TODO: Share.
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .font(.title3)
        .fontWeight(.semibold)
        .foregroundColor(Color.accentColor)
    }
}

struct InteractionRow_Previews: PreviewProvider {
    static var previews: some View {
        InteractionRow(statusData: PreviewData.getStatus())
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
