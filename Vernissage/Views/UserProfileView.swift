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
    @State private var state: ViewState = .loading
    
    var body: some View {
        self.mainBody()
            .navigationBarTitle(self.accountDisplayName ?? self.accountUserName)
            .toolbar {
                if let account = self.account {
                    if self.applicationState.account?.id != account.id {
                        self.getTrailingAccountToolbar(account: account)
                    } else {
                        self.getTrailingProfileToolbar(account: account)
                    }
                }
            }
    }
    
    @ViewBuilder
    private func mainBody() -> some View {
        switch state {
        case .loading:
            LoadingIndicator()
                .task {
                    await self.loadData()
                }
        case .loaded:
            if let account = self.account {
                ScrollView {
                    UserProfileHeader(account: account, relationship: relationship)
                    UserProfileStatuses(accountId: account.id)
                }
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadData()
            }
            .padding()
        }
    }
    
    private func loadData() async {
        do {
            async let relationshipTask = AccountService.shared.relationships(withId: self.accountId, for: self.applicationState.account)
            async let accountTask = AccountService.shared.account(withId: self.accountId, for: self.applicationState.account)
            
            // Wait for download account and relationships.
            (self.relationship, self.account) = try await (relationshipTask, accountTask)
            
            self.state = .loaded
        } catch {
            ErrorService.shared.handle(error, message: "Error during download account from server.", showToastr: !Task.isCancelled)
            self.state = .error(error)
        }
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
                
                NavigationLink(value: RouteurDestinations.statuses(listType: .favourites)) {
                    Label("Favourites", systemImage: "hand.thumbsup")
                }
                
                NavigationLink(value: RouteurDestinations.statuses(listType: .bookmarks)) {
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
                    account: account.id,
                    for: self.applicationState.account
                ) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await AccountService.shared.mute(
                    account: account.id,
                    for: self.applicationState.account
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
                    account: account.id,
                    for: self.applicationState.account
                ) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await AccountService.shared.block(
                    account: account.id,
                    for: self.applicationState.account
                ) {
                    self.relationship = relationship
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Block/unblock action failed.", showToastr: true)
        }
    }
}
