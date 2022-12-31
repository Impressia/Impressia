//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonSwift

struct DetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State public var current: ImageStatus
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                Image(uiImage: current.image)
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) {
                    HStack (alignment: .center) {
                        AsyncImage(url: current.status.account?.avatar) { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "person.circle")
                                .resizable()
                                .foregroundColor(Color("mainTextColor"))
                        }
                        .frame(width: 48.0, height: 48.0)
                        
                        VStack (alignment: .leading) {
                            Text(current.status.account?.displayName ?? current.status.account?.username ?? "")
                                .foregroundColor(Color("displayNameColor"))
                            Text("@\(current.status.account?.username ?? "unknown")")
                                .foregroundColor(Color("lightGrayColor"))
                                .font(.footnote)
                        }
                        .padding(.leading, 8)
                    }
                    
                    HTMLFormattedText(current.status.content)
                    
                    VStack (alignment: .leading) {
                        LabelIconView(iconName: "camera", value: "SONY ILCE-7M3")
                        LabelIconView(iconName: "camera.aperture", value: "Viltrox 24mm F1.8 E")
                        LabelIconView(iconName: "timelapse", value: "24.0 mm, f/1.8, 1/640s, ISO 100")
                        LabelIconView(iconName: "calendar", value: "2 Oct 2022")
                    }
                    .foregroundColor(Color("lightGrayColor"))
                    
                    HStack (alignment: .top) {
                        TagView {
                            // Favorite
                        } content: {
                            HStack {
                                Image(systemName: current.status.favourited ? "heart.fill" : "heart")
                                Text("\(current.status.favouritesCount) likes")
                            }
                        }
                        
                        TagView {
                            // Reboost
                        } content: {
                            HStack {
                                Image(systemName: current.status.reblogged ? "arrowshape.turn.up.forward.fill" : "arrowshape.turn.up.forward")
                                Text("\(current.status.reblogsCount) boosts")
                            }
                        }
                        
                        Spacer()
                        
                        TagView {
                            // Bookmark
                        } content: {
                            Image(systemName: current.status.bookmarked ? "bookmark.fill" : "bookmark")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("mainTextColor"))
                }
                .padding(8)
            }
        }
        .navigationBarTitle("Details")
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
        // DetailsView(current: ImageStatus(id: "123", image: UIImage(), status: Status(from: <#T##Decoder#>)))
    }
}
