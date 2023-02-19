//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import UIKit
import CoreData
import PixelfedKit

struct MainView: View {
    enum Sheet: String, Identifiable {
        case settings, compose
        var id: String { rawValue }
    }
    
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath
    @EnvironmentObject var tipsStore: TipsStore
    
    @State private var navBarTitle: String = "Home"
    @State private var viewMode: ViewMode = .home {
        didSet {
            self.navBarTitle = self.getViewTitle(viewMode: viewMode)
        }
    }
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.acct, order: .forward)]) var dbAccounts: FetchedResults<AccountData>
    
    private enum ViewMode {
        case home, local, federated, profile, notifications, trending
    }
    
    var body: some View {
        self.getMainView()
        .navigationBarTitle(navBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            self.getLeadingToolbar()
            self.getPrincipalToolbar()
            self.getTrailingToolbar()
        }
        .onChange(of: tipsStore.status) { status in
            if status == .successful {
                withAnimation(.spring()) {
                    self.routerPath.presentedOverlay = .successPayment
                    self.tipsStore.reset()
                }
            }
        }
    }
    
    @ViewBuilder
    private func getMainView() -> some View {
        switch self.viewMode {
        case .home:
            HomeFeedView(accountId: applicationState.account?.id ?? String.empty())
                .id(applicationState.account?.id ?? String.empty())
        case .trending:
            TrendStatusesView(accountId: applicationState.account?.id ?? String.empty())
                .id(applicationState.account?.id ?? String.empty())
        case .local:
            StatusesView(listType: .local)
                .id(applicationState.account?.id ?? String.empty())
        case .federated:
            StatusesView(listType: .federated)
                .id(applicationState.account?.id ?? String.empty())
        case .profile:
            if let accountData = self.applicationState.account {
                UserProfileView(accountId: accountData.id,
                                accountDisplayName: accountData.displayName,
                                accountUserName: accountData.acct)
                .id(applicationState.account?.id ?? String.empty())
            }
        case .notifications:
            if let accountData = self.applicationState.account {
                NotificationsView(accountId: accountData.id)
                    .id(applicationState.account?.id ?? String.empty())
            }
        }
    }
    
    @ToolbarContentBuilder
    private func getPrincipalToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Menu {
                Button {
                    HapticService.shared.fireHaptic(of: .tabSelection)
                    viewMode = .home
                } label: {
                    HStack {
                        Text(self.getViewTitle(viewMode: .home))
                        Image(systemName: "house")
                    }
                }

                Button {
                    HapticService.shared.fireHaptic(of: .tabSelection)
                    viewMode = .trending
                } label: {
                    HStack {
                        Text(self.getViewTitle(viewMode: .trending))
                        Image(systemName: "chart.line.uptrend.xyaxis")
                    }
                }
                
                Button {
                    HapticService.shared.fireHaptic(of: .tabSelection)
                    viewMode = .local
                } label: {
                    HStack {
                        Text(self.getViewTitle(viewMode: .local))
                        Image(systemName: "text.redaction")
                    }
                }

                Button {
                    HapticService.shared.fireHaptic(of: .tabSelection)
                    viewMode = .federated
                } label: {
                    HStack {
                        Text(self.getViewTitle(viewMode: .federated))
                        Image(systemName: "globe.europe.africa")
                    }
                }
                
                Divider()

                Button {
                    HapticService.shared.fireHaptic(of: .tabSelection)
                    viewMode = .profile
                } label: {
                    HStack {
                        Text(self.getViewTitle(viewMode: .profile))
                        Image(systemName: "person")
                    }
                }
                
                Button {
                    HapticService.shared.fireHaptic(of: .tabSelection)
                    viewMode = .notifications
                } label: {
                    HStack {
                        Text(self.getViewTitle(viewMode: .notifications))
                        Image(systemName: "bell.badge")
                    }
                }
            } label: {
                HStack {
                    Text(navBarTitle)
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                }
                .frame(width: 150)
                .foregroundColor(.mainTextColor)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func getLeadingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Menu {
                ForEach(self.dbAccounts) { account in
                    Button {
                        HapticService.shared.fireHaptic(of: .buttonPress)
                        self.tryToSwitch(account)
                    } label: {
                        if self.applicationState.account?.id == account.id {
                            Label(account.displayName ?? account.acct, systemImage: "checkmark")
                        } else {
                            Text(account.displayName ?? account.acct)
                        }
                    }
                }

                Divider()
                
                Button {
                    HapticService.shared.fireHaptic(of: .buttonPress)
                    self.routerPath.presentedSheet = .settings
                } label: {
                    Label("Settings", systemImage: "gear")
                }
            } label: {
                if let avatarData = self.applicationState.account?.avatarData, let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .clipShape(self.applicationState.avatarShape.shape())
                        .frame(width: 32.0, height: 32.0)
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.lightGrayColor)
                        .clipShape(AvatarShape.circle.shape())
                        .background(
                            AvatarShape.circle.shape()
                        )
                }
            }
        }
    }
    
    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        if viewMode == .local || viewMode == .home || viewMode == .federated || viewMode == .trending {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    HapticService.shared.fireHaptic(of: .buttonPress)
                    self.routerPath.presentedSheet = .newStatusEditor
                } label: {
                    Image(systemName: "square.and.pencil")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.accentColor, Color.mainTextColor)
                        .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func getViewTitle(viewMode: ViewMode) -> String {
        switch viewMode {
        case .home:
            return "Home"
        case .trending:
            return "Trending"
        case .local:
            return "Local"
        case .federated:
            return "Federated"
        case .profile:
            return "Profile"
        case .notifications:
            return "Notifications"
        }
    }
    
    private func tryToSwitch(_ account: AccountData) {
        Task {
            // Verify access token correctness.
            let authorizationSession = AuthorizationSession()
            await AuthorizationService.shared.verifyAccount(session: authorizationSession, currentAccount: account) { accountData in
                guard let accountData = accountData else {
                    ToastrService.shared.showError(subtitle: "Cannot switch accounts.")
                    return
                }

                Task { @MainActor in
                    let accountModel = AccountModel(accountData: accountData)
                    self.applicationState.account = accountModel
                    self.client.setAccount(account: accountModel)
                    self.applicationState.lastSeenStatusId = account.lastSeenStatusId
                    self.applicationState.amountOfNewStatuses = 0
                    
                    ApplicationSettingsHandler.shared.setAccountAsDefault(accountData: accountData)
                }
            }
        }
    }
}

