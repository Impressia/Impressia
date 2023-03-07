//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import PixelfedKit

struct UserProfileView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    
    @Environment(\.dismiss) private var dismiss
    
    @State public var accountId: String
    @State public var accountDisplayName: String?
    @State public var accountUserName: String

    @State private var account: Account? = nil
    @State private var relationship: Relationship? = nil
    @State private var state: ViewState = .loading
    
    var body: some View {
        self.mainBody()
            .navigationTitle(self.accountDisplayName ?? self.accountUserName)
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
                    UserProfileHeaderView(account: account, relationship: relationship)
                    UserProfileStatusesView(accountId: account.id)
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
            if self.accountId.isEmpty {
                let accountsFromApi = try await self.client.search?.search(query: self.accountUserName, resultsType: .accounts)
                if let accountFromApi = accountsFromApi?.accounts.first {
                    self.accountId = accountFromApi.id
                } else {
                    ToastrService.shared.showError(title: "Account not exists", imageSystemName: "exclamationmark.octagon")
                    dismiss()
                    
                    return
                }
            }
            
            async let relationshipTask = self.client.accounts?.relationships(withId: self.accountId)
            async let accountTask = self.client.accounts?.account(withId: self.accountId)
            
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
                
                NavigationLink(value: RouteurDestinations.favourites) {
                    Label("Favourites", systemImage: "hand.thumbsup")
                }
                
                NavigationLink(value: RouteurDestinations.bookmarks) {
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
                if let relationship = try await self.client.accounts?.unmute(account: account.id) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await self.client.accounts?.mute(account: account.id) {
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
                if let relationship = try await self.client.accounts?.unblock(account: account.id) {
                    self.relationship = relationship
                }
            } else {
                if let relationship = try await self.client.accounts?.block(account: account.id) {
                    self.relationship = relationship
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Block/unblock action failed.", showToastr: true)
        }
    }
}
