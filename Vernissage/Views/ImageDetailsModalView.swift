//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI
import MastodonSwift

struct ImageDetailsModalView: View {
    @Environment(\.dismiss) private var dismiss
    @State public var current: ImageStatus
    
    var body: some View {
        VStack {
            DismissButtonView { dismiss() }

            ScrollView {
                VStack (alignment: .leading) {
                    Image(uiImage: current.image)
                        .resizable().aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            dismiss()
                        }
                    
                    VStack(alignment: .leading) {
                        HStack (alignment: .center) {
                            AsyncImage(url: current.status.account?.avatar) { image in
                                image
                                    .resizable()
                                    .clipShape(Circle())
                                    .shadow(radius: 10)
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(height: 60)
                            .frame(width: 60)
                            
                            VStack (alignment: .leading) {
                                Text(current.status.account?.displayName ?? current.status.account?.username ?? "")
                                    .foregroundColor(Color("displayNameColor"))
                                Text("@\(current.status.account?.username ?? "unknown")")
                                    .foregroundColor(Color("userNameColor"))
                                    .font(.footnote)
                            }
                            .padding(.leading, 8)
                        }
                        
                        HTMLFormattedText(current.status.content)
                        
                        HStack (alignment: .top) {
                            Image(systemName: current.status.favourited ? "heart.fill" : "heart")
                            Text("\(current.status.favouritesCount) likes")
                            
                            Image(systemName: "arrow.2.squarepath")
                                .padding(.leading, 16)
                            Text("\(current.status.reblogsCount) boosts")
                        }
                        .font(.footnote)
                        .foregroundColor(Color("mainTextColor"))
                    }
                    .padding(8)
                }
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                if value.location.y - value.startLocation.y > 150 {
                    dismiss()
                }
            }
        )
    }
}

struct FullScreenModalView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
        // FullScreenModalView(current: ImageStatus(id: "123", image: UIImage(), status: Status(from: <#T##Decoder#>)))
    }
}
