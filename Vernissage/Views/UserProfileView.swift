//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonSwift

struct UserProfileView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    
    @State public var accountId: String
    @State public var accountDisplayName: String?
    @State public var accountUserName: String
    @State private var account: Account? = nil
    @State private var relationship: Relationship? = nil
    @State private var statuses: [Status] = []
    @State private var isDuringRelationshipAction = false
    
    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    
    var body: some View {
        ScrollView {
            if let account = self.account {
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
                        
                        if self.applicationState.accountData?.id != self.accountId {
                            Button {
                                Task {
                                    Task { @MainActor in
                                        self.isDuringRelationshipAction = false
                                    }
                                    
                                    HapticService.shared.touch()
                                    self.isDuringRelationshipAction = true
                                    do {
                                        if let relationship = try await AccountService.shared.follow(
                                            forAccountId: self.accountId,
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
                                    LoadingIndicator()
                                } else {
                                    HStack {
                                        Image(systemName: relationship?.following == true ? "person.badge.minus" : "person.badge.plus")
                                        Text(relationship?.following == true ? "Unfollow" : (relationship?.followedBy == true ? "Follow back" : "Follow"))
                                    }
                                }
                            }
                            .disabled(isDuringRelationshipAction)
                            .buttonStyle(.borderedProminent)
                            .tint(relationship?.following == true ? .dangerColor : .accentColor)
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
                
                ForEach(self.statuses, id: \.id) { item in
                    VStack {
                        NavigationLink(destination: StatusView(statusId: item.id)
                            .environmentObject(applicationState)) {
                                ImageRowAsync(attachments: item.mediaAttachments)
                            }
                    }
                }
                
                LazyVStack {
                    if allItemsLoaded == false && firstLoadFinished == true {
                        LoadingIndicator()
                            .onAppear {
                                Task {
                                    do {
                                        try await self.loadMoreStatuses()
                                    } catch {
                                        print("Error \(error.localizedDescription)")
                                    }
                                }
                            }
                            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .center)
                    }
                }
                
            } else {
                LoadingIndicator()
            }
        }
        .navigationBarTitle(self.accountDisplayName ?? self.accountUserName)
        .onAppear {
            Task {
                do {
                    try await self.loadData()
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadData() async throws {
        async let relationshipTask = AccountService.shared.getRelationship(withId: self.accountId, forUser: self.applicationState.accountData)
        async let accountTask = AccountService.shared.getAccount(withId: self.accountId, and: self.applicationState.accountData)
        
        // Wait for download account and relationships.
        (self.relationship, self.account) = try await (relationshipTask, accountTask)
        
        self.statuses = try await AccountService.shared.getStatuses(forAccountId: self.accountId, andContext: self.applicationState.accountData)
        self.firstLoadFinished = true
        
        if self.statuses.count < 40 {
            self.allItemsLoaded = true
        }
    }
        
    private func loadMoreStatuses() async throws {
        if let lastStatusId = self.statuses.last?.id {
            let previousStatuses = try await AccountService.shared.getStatuses(
                forAccountId: self.accountId,
                andContext: self.applicationState.accountData,
                maxId: lastStatusId)

            if previousStatuses.count < 40 {
                self.allItemsLoaded = true
            }

            self.statuses.append(contentsOf: previousStatuses)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(accountId: "", accountDisplayName: "", accountUserName: "")
    }
}
