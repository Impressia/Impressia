//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonSwift

struct CommentsSection: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var applicationState: ApplicationState

    @State public var statusId: String
    @State public var withDivider = true
    @State private var context: Context?
    
    var onNewStatus: ((_ context: Status) -> Void)?

    private let contentWidth = Int(UIScreen.main.bounds.width) - 50
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let context = context {
                ForEach(context.descendants, id: \.id) { status in
                    VStack(alignment: .leading, spacing: 0) {

                        if withDivider {
                            Divider()
                                .foregroundColor(.mainTextColor)
                                .padding(0)
                        }
                                                
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
                        
                        if self.applicationState.showInteractionStatusId == status.id {
                            VStack (alignment: .leading, spacing: 0) {
                                InteractionRow(statusId: status.id,
                                               repliesCount: status.repliesCount,
                                               reblogged: status.reblogged,
                                               reblogsCount: status.reblogsCount,
                                               favourited: status.favourited,
                                               favouritesCount: status.favouritesCount,
                                               bookmarked: status.bookmarked) {
                                    self.onNewStatus?(status)
                                }
                                .foregroundColor(self.getInteractionRowTextColor())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .background(Color.lightGrayColor.opacity(0.5))
                            .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                        }
                        
                        CommentsSection(statusId: status.id, withDivider: false)  { context in
                            self.onNewStatus?(context)
                        }
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
    
    private func getUserName(status: Status) -> String {
        return status.account?.displayName ?? status.account?.acct ?? status.account?.username ?? ""
    }
    
    private func getInteractionRowTextColor() -> Color {
        return self.colorScheme == .dark ? Color.black : Color.white
    }
    
    private func getSelectedRowColor(status: Status) -> Color {
        return self.applicationState.showInteractionStatusId == status.id ? Color.selectedRowColor : Color.systemBackground
    }
}

struct CommentsSection_Previews: PreviewProvider {
    static var previews: some View {
        CommentsSection(statusId: "", withDivider: true)
    }
}
