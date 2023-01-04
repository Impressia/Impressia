//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonSwift

struct CommentsSection: View {
    @EnvironmentObject var applicationState: ApplicationState

    @State public var statusId: String
    @State public var withDivider = true
    @State private var context: Context?
    
    private let contentWidth = Int(UIScreen.main.bounds.width) - 50
    
    var body: some View {
        VStack {
            if let context = context {
                ForEach(context.descendants, id: \.id) { status in
                    HStack (alignment: .top) {
                        AsyncImage(url: status.account?.avatar) { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "person.circle")
                                .resizable()
                                .foregroundColor(Color("MainTextColor"))
                        }
                        .frame(width: 32.0, height: 32.0)
                        
                        VStack (alignment: .leading) {
                            HStack (alignment: .top) {
                                Text(status.account?.displayName ?? status.account?.username ?? "")
                                    .foregroundColor(Color("DisplayNameColor"))
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                Text("@\(status.account?.username ?? "")")
                                    .foregroundColor(Color("LightGrayColor"))
                                    .font(.footnote)
                                
                                Spacer()
                                
                                Text(status.createdAt.toRelative(.isoDateTimeMilliSec))
                                    .foregroundColor(Color("LightGrayColor").opacity(0.5))
                                    .font(.footnote)

                                /*
                                Image(systemName: "message")
                                    .foregroundColor(Color.accentColor)
                                Image(systemName: "hand.thumbsup")
                                    .foregroundColor(Color.accentColor)
                                 */
                            }
                            .padding(.bottom, -10)
                            
  
                            
                            HTMLFormattedText(status.content, withFontSize: 14, andWidth: contentWidth)
                                .padding(.leading, -4)
                            
                            if status.mediaAttachments.count > 0 {
                                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: status.mediaAttachments.count == 1 ? 1 : 2), alignment: .center, spacing: 4) {
                                    ForEach(status.mediaAttachments, id: \.id) { attachment in
                                        AsyncImage(url: status.mediaAttachments[0].url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .frame(height: status.mediaAttachments.count == 1 ? 200 : 100)
                                                .cornerRadius(10)
                                                .shadow(color: Color("MainTextColor").opacity(0.3), radius: 2)
                                        } placeholder: {
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(minWidth: 0, maxWidth: .infinity)
                                                .frame(height: status.mediaAttachments.count == 1 ? 200 : 100)
                                                .foregroundColor(Color("MainTextColor"))
                                                .opacity(0.05)
                                        }
                                    }
                                }
                                .padding(.bottom, 8)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)

                    
                    CommentsSection(statusId: status.id, withDivider: false)
                    
                    if withDivider {
                        Rectangle()
                            .size(width: UIScreen.main.bounds.width, height: 4)
                            .fill(Color("MainTextColor"))
                            .opacity(0.1)
                    }
                }
            }
        }
        .task {
            do {
                if let accountData = applicationState.accountData {
                    self.context = try await TimelineService.shared.getComments(
                        for: statusId,
                        and: accountData)
                }
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
    }
}

struct CommentsSection_Previews: PreviewProvider {
    static var previews: some View {
        CommentsSection(statusId: "", withDivider: true)
    }
}
