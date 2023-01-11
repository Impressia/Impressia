//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

struct UserProfileView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    
    @State public var accountId: String
    @State public var accountDisplayName: String?
    @State public var accountUserName: String
    @State private var account: Account? = nil
    @State private var relationship: Relationship? = nil
    
    var body: some View {
        VStack {
            if let account = self.account {
                ScrollView {
                    UserProfileHeader(account: account, relationship: relationship)
                    UserProfileStatuses(accountId: account.id)
                }
            } else {
                Spacer()
                LoadingIndicator()
                Spacer()
            }
        }
        .navigationBarTitle(self.accountDisplayName ?? self.accountUserName)
        .task {
            do {
                try await self.loadData()
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    private func loadData() async throws {
        async let relationshipTask = AccountService.shared.getRelationship(withId: self.accountId, forUser: self.applicationState.accountData)
        async let accountTask = AccountService.shared.getAccount(withId: self.accountId, and: self.applicationState.accountData)
        
        // Wait for download account and relationships.
        (self.relationship, self.account) = try await (relationshipTask, accountTask)
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileView(accountId: "", accountDisplayName: "", accountUserName: "")
    }
}
