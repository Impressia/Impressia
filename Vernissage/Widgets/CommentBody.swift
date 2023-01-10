//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import SwiftUI
import MastodonKit

struct CommentBody: View {
    @EnvironmentObject var applicationState: ApplicationState

    @State var status: Status
    private let contentWidth = Int(UIScreen.main.bounds.width) - 50
    
    var body: some View {
        HStack (alignment: .top) {
            
            if let account = status.account {
                NavigationLink(destination: UserProfileView(
                    accountId: account.id,
                    accountDisplayName: account.displayName,
                    accountUserName: account.acct)
                    .environmentObject(applicationState)) {
                        AsyncImage(url: account.avatar) { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "person.circle")
                                .resizable()
                                .foregroundColor(.mainTextColor)
                        }
                        .frame(width: 32.0, height: 32.0)
                    }
            }
            
            VStack (alignment: .leading, spacing: 0) {
                HStack (alignment: .top) {
                    Text(self.getUserName(status: status))
                        .foregroundColor(.mainTextColor)
                        .font(.footnote)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(status.createdAt.toRelative(.isoDateTimeMilliSec))
                        .foregroundColor(.lightGrayColor)
                        .font(.footnote)
                }
                
                HTMLFormattedText(status.content, withFontSize: 14, andWidth: contentWidth)
                    .padding(.top, -4)
                    .padding(.leading, -4)
                
                if status.mediaAttachments.count > 0 {
                    LazyVGrid(
                        columns: status.mediaAttachments.count == 1 ? [GridItem(.flexible())]: [GridItem(.flexible()), GridItem(.flexible())],
                        alignment: .center,
                        spacing: 4
                    ) {
                        ForEach(status.mediaAttachments, id: \.id) { attachment in
                            AsyncImage(url: attachment.url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(height: status.mediaAttachments.count == 1 ? 200 : 100)
                                    .cornerRadius(10)
                                    .shadow(color: .mainTextColor.opacity(0.3), radius: 2)
                            } placeholder: {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .frame(height: status.mediaAttachments.count == 1 ? 200 : 100)
                                    .foregroundColor(.mainTextColor)
                                    .opacity(0.05)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .onTapGesture {
                withAnimation(.linear(duration: 0.3)) {
                    if status.id == self.applicationState.showInteractionStatusId {
                        self.applicationState.showInteractionStatusId = ""
                    } else {
                        self.applicationState.showInteractionStatusId = status.id
                    }
                }
            }
        }
        .padding(8)
        .background(self.getSelectedRowColor(status: status))
    }
    
    private func getUserName(status: Status) -> String {
        return status.account?.displayName ?? status.account?.acct ?? status.account?.username ?? ""
    }
    
    private func getSelectedRowColor(status: Status) -> Color {
        return self.applicationState.showInteractionStatusId == status.id ? Color.selectedRowColor : Color.systemBackground
    }
}

struct CommentBody_Previews: PreviewProvider {
    static var previews: some View {
        CommentBody(status: Status(id: "", content: "", application: Application(name: "")))
    }
}
