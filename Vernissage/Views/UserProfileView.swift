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
    
    var body: some View {
        VStack(alignment: .leading) {
            if let account = self.account {

                HStack(alignment: .center) {
                    AsyncImage(url: account.avatar) { image in
                        image
                            .resizable()
                            .clipShape(Circle())
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .resizable()
                            .foregroundColor(Color("MainTextColor"))
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
                        .foregroundColor(Color("DisplayNameColor"))
                        .font(.footnote)
                        .fontWeight(.bold)
                    Text("@\(account.username)")
                        .foregroundColor(Color("LightGrayColor"))
                        .font(.footnote)
                    
                    Spacer()
                    
                    Button {
                        // Folllow/Unfollow
                    } label: {
                        Text("Follow")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)

                }
                
                if let note = account.note {
                    HTMLFormattedText(note, withFontSize: 14, andWidth: Int(UIScreen.main.bounds.width) - 16)
                        .padding(.top, -10)
                        .padding(.leading, -4)
                }
                
                Text("Joined \(account.createdAt.toRelative(.isoDateTimeMilliSec))")
                    .foregroundColor(Color("LightGrayColor").opacity(0.5))
                    .font(.footnote)
                
                Spacer()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
        .padding()
        .navigationBarTitle(self.accountDisplayName ?? self.accountUserName)
        .onAppear {
            Task {
                do {
                    if let account = try await AccountService.shared.getAccount(
                        withId: self.accountId,
                        and: self.applicationState.accountData
                    ) {
                        self.account = account
                    }
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
