//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonSwift

struct UserProfileView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @State public var accountId: String
    @State public var accountDisplayName: String?
    @State public var accountUserName: String
    @State private var account: Account? = nil
    @State private var relationship: Relationship? = nil
    @State private var statuses: [Status] = []
    
    private static let initialColumns = 1
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    
    var body: some View {
        ScrollView {
            if let account = self.account {
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        AsyncImage(url: account.avatar) { image in
                            image
                                .resizable()
                                .clipShape(Circle())
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "person.circle")
                                .resizable()
                                .foregroundColor(Color.mainTextColor)
                        }
                        .frame(width: 96.0, height: 96.0)
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            Text("\(account.statusesCount)")
                                .font(.title3)
                            Text("Posts")
                                .font(.subheadline)
                                .opacity(0.6)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            Text("\(account.followersCount)")
                                .font(.title3)
                            Text("Followers")
                                .font(.subheadline)
                                .opacity(0.6)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            Text("\(account.followingCount)")
                                .font(.title3)
                            Text("Following")
                                .font(.subheadline)
                                .opacity(0.6)
                        }
                    }
                    
                    HStack (alignment: .center) {
                        Text(account.displayName ?? account.username)
                            .foregroundColor(Color.mainTextColor)
                            .font(.footnote)
                            .fontWeight(.bold)
                        Text("@\(account.username)")
                            .foregroundColor(Color.lightGrayColor)
                            .font(.footnote)
                        
                        Spacer()
                        
                        Button {
                            // TODO: Folllow/Unfollow.
                        } label: {
                            HStack {
                                Image(systemName: relationship?.following == true ? "person.badge.minus" : "person.badge.plus")
                                Text(relationship?.following == true ? "Unfollow" : (relationship?.followedBy == true ? "Follow back" : "Follow"))
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(relationship?.following == true ? Color.dangerColor : .accentColor)
                        
                    }
                    
                    if let note = account.note {
                        HTMLFormattedText(note, withFontSize: 14, andWidth: Int(UIScreen.main.bounds.width) - 16)
                            .padding(.top, -10)
                            .padding(.leading, -4)
                    }
                    
                    Text("Joined \(account.createdAt.toRelative(.isoDateTimeMilliSec))")
                        .foregroundColor(Color.lightGrayColor.opacity(0.5))
                        .font(.footnote)
                    
                }
                .padding()
                
                LazyVGrid(columns: gridColumns) {
                    ForEach(self.statuses, id: \.id) { item in
                        NavigationLink(destination: DetailsView(statusId: item.id)
                            .environmentObject(applicationState)) {
                                ImageRowAsync(attachments: item.mediaAttachments)
                            }
                    }
                }
                
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .navigationBarTitle(self.accountDisplayName ?? self.accountUserName)
        .onAppear {
            Task {
                do {
                    async let relationshipTask = AccountService.shared.getRelationship(withId: self.accountId, forUser: self.applicationState.accountData)
                    async let accountTask = AccountService.shared.getAccount(withId: self.accountId, and: self.applicationState.accountData)

                    (self.relationship, self.account) = try await (relationshipTask, accountTask)
                    
                    self.statuses = try await AccountService.shared.getStatuses(forAccountId: self.accountId, andContext: self.applicationState.accountData)
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(accountId: "", accountDisplayName: "", accountUserName: "")
    }
}
