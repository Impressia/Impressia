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
    @State private var firstLoadFinished = false
    
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
        .toolbar {
            if let account = self.account {
                if self.applicationState.accountData?.id != account.id {
                    self.getTrailingAccountToolbar(account: account)
                } else {
                    self.getTrailingProfileToolbar(account: account)
                }
            }
        }
        .task {
            do {
                try await self.loadData()
            } catch {
                ErrorService.shared.handle(error, message: "Error during download account from server.", showToastr: !Task.isCancelled)
            }
        }
    }
    
    private func loadData() async throws {
        guard firstLoadFinished == false else {
            return
        }

        async let relationshipTask = AccountService.shared.relationships(withId: self.accountId, forUser: self.applicationState.accountData)
        async let accountTask = AccountService.shared.account(withId: self.accountId, and: self.applicationState.accountData)
        
        // Wait for download account and relationships.
        self.firstLoadFinished = true
        (self.relationship, self.account) = try await (relationshipTask, accountTask)
    }
    
    @ToolbarContentBuilder
    private func getTrailingAccountToolbar(account: Account) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu (content: {
                if let accountUrl = account.url {
                    Link(destination: accountUrl) {
                        Label("Open in browser", systemImage: "safari")
                    }
                    
                    ShareLink(item: accountUrl) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                }
                
                Button {
                    Task {
                        await onMuteAccount(account: account)
                    }
                } label: {
                    if self.relationship?.muting == true {
                        Label("Unute", systemImage: "message.and.waveform.fill")
                    } else {
                        Label("Mute", systemImage: "message.and.waveform")
                    }
                }
                
                Button {
                    Task {
                        await onBlockAccount(account: account)
                    }
                } label: {
                    if self.relationship?.blocking == true {
                        Label("Unblock", systemImage: "hand.raised.fill")
                    } else {
                        Label("Block", systemImage: "hand.raised")
                    }
                }
                
            }, label: {
                Image(systemName: "gear")
                    .tint(.mainTextColor)
            })
            .tint(.accentColor)
        }
    }
    

    @ToolbarContentBuilder
    private func getTrailingProfileToolbar(account: Account) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu (content: {
                if let accountUrl = account.url {
                    Link(destination: accountUrl) {
                        Label("Open in browser", systemImage: "safari")
                    }
                    
                    ShareLink(item: accountUrl) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    
                    Divider()
                }
                
                NavigationLink(destination: StatusesView(accountId: applicationState.accountData?.id ?? String.empty(), listType: .favourites)
                    .environmentObject(applicationState)
                ) {
                    Label("Favourites", systemImage: "hand.thumbsup")
                }
                
                NavigationLink(destination: StatusesView(accountId: applicationState.accountData?.id ?? String.empty(), listType: .bookmarks)
                    .environmentObject(applicationState)
                ) {
                    Label("Bookmarks", systemImage: "bookmark")
                }
            }, label: {
                Image(systemName: "gear")
                    .tint(.mainTextColor)
            })
            .tint(.accentColor)
        }
    }
    
    private func onMuteAccount(account: Account) async {
        do {
            if self.relationship?.muting == true {
                if let relationship = try await AccountService.shared.unmute(
                    forAccountId: account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await AccountService.shared.mute(
                    forAccountId: account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Muting/unmuting action failed.", showToastr: true)
        }
    }
    
    private func onBlockAccount(account: Account) async {
        do {
            if self.relationship?.blocking == true {
                if let relationship = try await AccountService.shared.unblock(
                    forAccountId: account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await AccountService.shared.block(
                    forAccountId: account.id,
                    andContext: self.applicationState.accountData
                ) {
                    self.relationship = relationship
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Block/unblock action failed.", showToastr: true)
        }
    }
}
