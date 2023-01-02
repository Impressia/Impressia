//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonSwift
import AVFoundation

struct DetailsView: View {
    @Environment(\.dismiss) private var dismiss

    @State public var statusData: StatusData
    @State private var height: Double = 0.0
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                TabView {
                    ForEach(statusData.attachments(), id: \.self) { attachment in
                        if let image = UIImage(data: attachment.data) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
                .frame(height: CGFloat(self.height))
                .tabViewStyle(PageTabViewStyle())
                
                VStack(alignment: .leading) {
                    HStack (alignment: .center) {
                        AsyncImage(url: statusData.accountAvatar) { image in
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
                            Text(statusData.accountDisplayName ?? statusData.accountUsername)
                                .foregroundColor(Color("displayNameColor"))
                            Text("@\(statusData.accountUsername)")
                                .foregroundColor(Color("lightGrayColor"))
                                .font(.footnote)
                        }
                        .padding(.leading, 8)
                    }
                    
                    HTMLFormattedText(statusData.content)
                    
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
                                Image(systemName: statusData.favourited ? "heart.fill" : "heart")
                                Text("\(statusData.favouritesCount) likes")
                            }
                        }
                        
                        TagView {
                            // Reboost
                        } content: {
                            HStack {
                                Image(systemName: statusData.reblogged ? "arrowshape.turn.up.forward.fill" : "arrowshape.turn.up.forward")
                                Text("\(statusData.reblogsCount) boosts")
                            }
                        }
                        
                        Spacer()
                        
                        TagView {
                            // Bookmark
                        } content: {
                            Image(systemName: statusData.bookmarked ? "bookmark.fill" : "bookmark")
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("mainTextColor"))
                }
                .padding(8)
            }
        }
        .navigationBarTitle("Details")
        .onAppear {
            self.calculateImageHeight()
        }
    }
    
    private func calculateImageHeight() {
        var imageHeight = 0.0
        var imageWidth = 0.0
        
        for item in statusData.attachments() {
            if let image = UIImage(data: item.data) {
                if image.size.height > imageHeight {
                    imageHeight = image.size.height
                    imageWidth = image.size.width
                }
            }
        }
        
        let divider = imageWidth / UIScreen.main.bounds.size.width
        self.height = imageHeight / divider
    }
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
        // DetailsView(current: ImageStatus(id: "123", image: UIImage(), status: Status(from: <#T##Decoder#>)))
    }
}
