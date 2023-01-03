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
                                .foregroundColor(Color("mainTextColor"))
                        }
                        .frame(width: 32.0, height: 32.0)
                        
                        VStack (alignment: .leading) {
                            HStack (alignment: .top) {
                                Text(status.account?.displayName ?? status.account?.username ?? "")
                                    .foregroundColor(Color("displayNameColor"))
                                    .font(.footnote)
                                    .fontWeight(.bold)
                                Text("@\(status.account?.username ?? "")")
                                    .foregroundColor(Color("lightGrayColor"))
                                    .font(.footnote)
                            }
                            .padding(.bottom, -10)
                            
                            HTMLFormattedText(status.content, withFontSize: 14, andWidth: contentWidth)
                                .padding(.leading, -4)
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    CommentsSection(statusId: status.id, withDivider: false)
                    
                    if withDivider {
                        Rectangle()
                            .size(width: UIScreen.main.bounds.width, height: 4)
                            .fill(Color("mainTextColor"))
                            .opacity(0.05)
                    }
                }
            }
        }.task {
            do {
                if let accountData = applicationState.accountData {
                    self.context = try await TimelineService.shared.getComments(for: statusId, and: accountData)
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
