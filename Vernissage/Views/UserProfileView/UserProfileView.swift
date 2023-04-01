//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
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

    @StateObject private var relationship = RelationshipModel()
    @State private var account: Account?
    @State private var state: ViewState = .loading
    @State private var viewId = UUID().uuidString

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
                self.accountView(account: account)
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadData()
            }
            .padding()
        }
    }

    private func accountView(account: Account) -> some View {
        ScrollView {
            UserProfileHeaderView(account: account, relationship: relationship)
                .id(self.viewId)
            UserProfileStatusesView(accountId: account.id)
        }
        .onAppear {
            if let updatedProfile = self.applicationState.updatedProfile {
                self.account = nil
                self.account = updatedProfile
                self.applicationState.updatedProfile = nil
                self.viewId = UUID().uuidString
            }
        }
    }

    private func loadData() async {
        do {
            if self.accountId.isEmpty {
                let accountsFromApi = try await self.client.search?.search(query: self.accountUserName, resultsType: .accounts)
                if let accountFromApi = accountsFromApi?.accounts.first {
                    self.accountId = accountFromApi.id
                } else {
                    ToastrService.shared.showError(title: "userProfile.error.notExists", imageSystemName: "exclamationmark.octagon")
                    dismiss()

                    return
                }
            }

            async let relationshipTask = self.client.accounts?.relationships(withId: self.accountId)
            async let accountTask = self.client.accounts?.account(withId: self.accountId)

            // Wait for download account and relationships.
            let (relationshipFromApi, accountFromApi) = try await (relationshipTask, accountTask)

            if let relationshipFromApi {
                self.relationship.update(relationship: relationshipFromApi)
            } else {
                self.relationship.update(relationship: RelationshipModel())
            }

            self.account = accountFromApi

            self.state = .loaded
        } catch {
            ErrorService.shared.handle(error, message: "userProfile.error.loadingAccountFailed", showToastr: !Task.isCancelled)
            self.state = .error(error)
        }
    }

    @ToolbarContentBuilder
    private func getTrailingAccountToolbar(account: Account) -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu(content: {
                if let accountUrl = account.url {
                    Link(destination: accountUrl) {
                        Label(NSLocalizedString("userProfile.title.openInBrowser", comment: "Open in browser"), systemImage: "safari")
                    }

                    ShareLink(item: accountUrl) {
                        Label(NSLocalizedString("userProfile.title.share", comment: "Share"), systemImage: "square.and.arrow.up")
                    }

                    Divider()
                }

                Button {
                    Task {
                        await onMuteAccount(account: account)
                    }
                } label: {
                    if self.relationship.muting == true {
                        Label(NSLocalizedString("userProfile.title.unmute", comment: "Unute"), systemImage: "message.and.waveform.fill")
                    } else {
                        Label(NSLocalizedString("userProfile.title.mute", comment: "Mute"), systemImage: "message.and.waveform")
                    }
                }

                Button {
                    Task {
                        await onBlockAccount(account: account)
                    }
                } label: {
                    if self.relationship.blocking == true {
                        Label(NSLocalizedString("userProfile.title.unblock", comment: "Unblock"), systemImage: "hand.raised.fill")
                    } else {
                        Label(NSLocalizedString("userProfile.title.block", comment: "Block"), systemImage: "hand.raised")
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
            Menu(content: {
                if let accountUrl = account.url {
                    Link(destination: accountUrl) {
                        Label(NSLocalizedString("userProfile.title.openInBrowser", comment: "Open in browser"), systemImage: "safari")
                    }

                    ShareLink(item: accountUrl) {
                        Label(NSLocalizedString("userProfile.title.share", comment: "Share"), systemImage: "square.and.arrow.up")
                    }

                    Divider()
                }

                NavigationLink(value: RouteurDestinations.instance) {
                    Label(NSLocalizedString("userProfile.title.instance", comment: "Instance information"), systemImage: "server.rack")
                }

                Divider()

                NavigationLink(value: RouteurDestinations.accounts(listType: .blocks)) {
                    Label(NSLocalizedString("userProfile.title.blocks", comment: "Blocked accounts"), systemImage: "hand.raised.fill")
                }

                NavigationLink(value: RouteurDestinations.accounts(listType: .mutes)) {
                    Label(NSLocalizedString("userProfile.title.mutes", comment: "Muted accounts"), systemImage: "message.and.waveform.fill")
                }

                Divider()

                NavigationLink(value: RouteurDestinations.favourites) {
                    Label(NSLocalizedString("userProfile.title.favourites", comment: "Favourites"), systemImage: "hand.thumbsup")
                }

                NavigationLink(value: RouteurDestinations.bookmarks) {
                    Label(NSLocalizedString("userProfile.title.bookmarks", comment: "Bookmarks"), systemImage: "bookmark")
                }

                Divider()

                NavigationLink(value: RouteurDestinations.editProfile) {
                    Label(NSLocalizedString("userProfile.title.edit", comment: "Edit profile"), systemImage: "pencil")
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
            if self.relationship.muting == true {
                if let relationship = try await self.client.accounts?.unmute(account: account.id) {
                    ToastrService.shared.showSuccess("userProfile.title.unmuted", imageSystemName: "message.and.waveform")
                    withAnimation(.linear) {
                        self.relationship.muting = relationship.muting
                    }
                }
            } else {
                if let relationship = try await self.client.accounts?.mute(account: account.id) {
                    ToastrService.shared.showSuccess("userProfile.title.muted", imageSystemName: "message.and.waveform.fill")
                    withAnimation(.linear) {
                        self.relationship.muting = relationship.muting
                    }
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "userProfile.error.mute", showToastr: true)
        }
    }

    private func onBlockAccount(account: Account) async {
        do {
            if self.relationship.blocking == true {
                if let relationship = try await self.client.accounts?.unblock(account: account.id) {
                    ToastrService.shared.showSuccess("userProfile.title.unblocked", imageSystemName: "hand.raised")
                    withAnimation(.linear) {
                        self.relationship.blocking = relationship.blocking
                    }
                }
            } else {
                if let relationship = try await self.client.accounts?.block(account: account.id) {
                    ToastrService.shared.showSuccess("userProfile.title.blocked", imageSystemName: "hand.raised.fill")
                    withAnimation(.linear) {
                        self.relationship.blocking = relationship.blocking
                    }
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "userProfile.error.block", showToastr: true)
        }
    }
}
