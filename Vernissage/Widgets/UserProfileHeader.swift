//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonSwift

struct UserProfileHeader: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @State var account: Account
    @State var relationship: Relationship

    @State private var isDuringRelationshipAction = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                UserAvatar(accountAvatar: account.avatar, width: 96, height: 96)
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("\(account.statusesCount)")
                        .font(.title3)
                    Text("Posts")
                        .font(.subheadline)
                        .opacity(0.6)
                }
                
                Spacer()
                
                NavigationLink(destination: FollowersView(accountId: account.id)
                    .environmentObject(applicationState)
                ) {
                    VStack(alignment: .center) {
                        Text("\(account.followersCount)")
                            .font(.title3)
                        Text("Followers")
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }.foregroundColor(.mainTextColor)
                
                Spacer()
                
                NavigationLink(destination: FollowingView(accountId: account.id)
                    .environmentObject(applicationState)
                ) {
                    VStack(alignment: .center) {
                        Text("\(account.followingCount)")
                            .font(.title3)
                        Text("Following")
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }.foregroundColor(.mainTextColor)
            }
            
            HStack (alignment: .center) {
                VStack(alignment: .leading) {
                    Text(account.displayName ?? account.acct)
                        .foregroundColor(.mainTextColor)
                        .font(.footnote)
                        .fontWeight(.bold)
                    Text("@\(account.acct)")
                        .foregroundColor(.lightGrayColor)
                        .font(.footnote)
                }
                
                Spacer()
                
                if self.applicationState.accountData?.id != self.account.id {
                    Button {
                        Task {
                            defer {
                                Task { @MainActor in
                                    withAnimation {
                                        self.isDuringRelationshipAction = false
                                    }
                                }
                            }
                            
                            HapticService.shared.touch()
                            withAnimation {
                                self.isDuringRelationshipAction = true
                            }
                            
                            do {
                                if let relationship = try await AccountService.shared.follow(
                                    forAccountId: self.account.id,
                                    andContext: self.applicationState.accountData
                                ) {
                                    self.relationship = relationship
                                }
                            } catch {
                                print("Error \(error.localizedDescription)")
                            }
                        }
                    } label: {
                        if isDuringRelationshipAction {
                            LoadingIndicator(withText: false)
                                .transition(.opacity)
                        } else {
                            HStack {
                                Image(systemName: relationship.following == true ? "person.badge.minus" : "person.badge.plus")
                                Text(relationship.following == true ? "Unfollow" : (relationship.followedBy == true ? "Follow back" : "Follow"))
                            }
                            .transition(.opacity)
                        }
                    }
                    .disabled(isDuringRelationshipAction)
                    .buttonStyle(.borderedProminent)
                    .tint(relationship.following == true ? .dangerColor : .accentColor)
                }
            }
            
            if let note = account.note, !note.isEmpty {
                HTMLFormattedText(note, withFontSize: 14, andWidth: Int(UIScreen.main.bounds.width) - 16)
                    .padding(.top, -10)
                    .padding(.leading, -4)
            }
            
            Text("Joined \(account.createdAt.toRelative(.isoDateTimeMilliSec))")
                .foregroundColor(.lightGrayColor.opacity(0.5))
                .font(.footnote)
            
        }
        .padding()
    }
}

struct UserProfileHeader_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
        // UserProfileHeader(account: Account(), relationship: Relationship())
    }
}
