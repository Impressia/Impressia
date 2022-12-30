//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import UIKit
import CoreData
import MastodonSwift

struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var applicationState: ApplicationState

    @State private var navBarTitle: String = "Home"
    @State private var viewMode: ViewMode = .home {
        didSet {
            switch viewMode {
            case .home:
                self.navBarTitle = "Home"
            case .local:
                self.navBarTitle = "Local"
            case .federated:
                self.navBarTitle = "Federated"
            case .notifications:
                self.navBarTitle = "Notifications"
            }
        }
    }
    
    private enum ViewMode {
        case home, local, federated, notifications
    }
    
    var body: some View {
        self.getMainView()
        .navigationBarTitle(navBarTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            self.getLeadingToolbar()
            self.getPrincipalToolbar()
        }
        .task {
            do {
                try await loadData()
            } catch {
                print("Error", error)
            }
        }
    }
    
    @ViewBuilder
    private func getMainView() -> some View {
        switch self.viewMode {
        case .home:
            HomeFeedView()
        case .local:
            LocalFeedView()
        case .federated:
            FederatedFeedView()
        case .notifications:
            NotificationsView()
        }
    }
    
    @ToolbarContentBuilder
    private func getPrincipalToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Menu {
                Button {
                    viewMode = .home
                } label: {
                    HStack {
                        Text("Home")
                        Image(systemName: "house")
                    }
                }
                
                Button {
                    viewMode = .local
                } label: {
                    HStack {
                        Text("Local")
                        Image(systemName: "text.redaction")
                    }
                }

                Button {
                    viewMode = .federated
                } label: {
                    HStack {
                        Text("Global")
                        Image(systemName: "globe.europe.africa")
                    }
                }
                
                Button {
                    viewMode = .notifications
                } label: {
                    HStack {
                        Text("Notifications")
                        Image(systemName: "bell.badge")
                    }
                }
            } label: {
                HStack {
                    Text(navBarTitle)
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                }
                .frame(width: 150)
                .foregroundColor(Color.white)
            }
        }
    }
    
    @ToolbarContentBuilder
    private func getLeadingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                // Open settings view.
            } label: {
                if let avatarData = self.applicationState.accountData?.avatarData, let uiImage = UIImage(data: avatarData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .clipShape(Circle())
                        .shadow(radius: 10)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 32)
                        .frame(width: 32)
                } else {
                    Image(systemName: "person.circle")
                }
            }
        }
    }
    
    private func loadData() async throws {
        
        // Set account data from database.
        let accountDataFromDb = self.getAccountData()
        if let accountDataFromDb {
            self.applicationState.accountData = accountDataFromDb
            return
        }
        
        // Retrieve account data from API.
        let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI2MTQwOCIsImp0aSI6IjZjMDg4N2ZlZThjZjBmZjQ1N2RjZDQ5MTU2YjE2NzYyYmQ2MDQ1NDQ1MmEwYzEyMzVmNDA3YjY2YjFhYjU3ZjBjMTY2YjFmZmIyNjJlZDg2IiwiaWF0IjoxNjcyMDU5MDYwLjI3NDgyMSwibmJmIjoxNjcyMDU5MDYwLjI3NDgyNCwiZXhwIjoxNzAzNTk1MDYwLjI1MzM1Nywic3ViIjoiNjc4MjMiLCJzY29wZXMiOlsicmVhZCIsIndyaXRlIiwiZm9sbG93Il19.kGvg3lW8lF1X1mOTdgGgoXNyzwUIJz5hz5RJKK_WiSoBWDQNadhZDty7XMNF0IAPjxOSi6UaIx2av7_eH_65aNlKFw89bkm8bT_zFQW2V0KbADJ-NmE6X0B_NgU2CNoF5IPn6bhCFHCKMtV6MWAQ_db6DT-LXaGemMY3QimcJzCqQuXI_1ouiZ235T297uEPNTrLwtLq-x_UoO-wx254LStBalDIGDVHAa4by9IT-mvu-QXz7k8pH2NHKoX-9Ql_Y3G9RJJNqoOmWMU45Dyo2HaJKKEb1tkeJ9tA3LIYgbwnEbG2PJ7CE8CXxtakiCIflJZpzzOmq1jXLAsCJ1mHnc77o7NfMaB_hY-f8PEI6d2ttOdH8bNlreF2avznNAIVHg_bf-yv_4wKUCUe0QZMG_yWqOwOk6lyruvboSGKuI5RnYsJbXBoJTGMLON6jVmtiKPbHy-9jNcfFgShAc3D5kTO-8Avj9_RquqEh1TQF_S4ljmganxKzMihyMDLK1OVcXzCFO6FKlCw7YKvbfJk1Qrn9kPBrVDM5jzIyXAmqRd1ivcE9nAdYb2l7KnxW_pi31uT0IdJMpTkZrUQSDMyEnj0HgV6Yd5BDlLG6Cnk8GXATTcU-a1pgE13OtWsCpD2cZQm-tOsFHWBDvY-BA0RtTvQAyEUxRIP9NjHe8rSR90"
        
        let client = MastodonClient(baseURL: URL(string: "https://pixelfed.social")!)
            .getAuthenticated(token: accessToken)
        
        // Get account information from server.
        let account = try await client.verifyCredentials()
        
        // Create account object in database.
        let accountData = AccountData(context: viewContext)
        accountData.id = account.id
        accountData.username = account.username
        accountData.acct = account.acct
        accountData.displayName = account.displayName
        accountData.note = account.note
        accountData.url = account.url
        accountData.avatar = account.avatar
        accountData.header = account.header
        accountData.locked = account.locked
        accountData.createdAt = account.createdAt
        accountData.followersCount = Int32(account.followersCount)
        accountData.followingCount = Int32(account.followingCount)
        accountData.statusesCount = Int32(account.statusesCount)
        accountData.accessToken = accessToken
        
        // Download avatar image.
        if let avatarUrl = account.avatar {
            let avatarData = try await RemoteFileService.shared.fetchData(url: avatarUrl)
            accountData.avatarData = avatarData
        }
        
        // Save account data in database and in application state.
        try self.viewContext.save()
        self.applicationState.accountData = accountData
    }
    
    private func getAccountData() -> AccountData? {
        let fetchRequest: NSFetchRequest<AccountData> = AccountData.fetchRequest()

        do {
            return try self.viewContext.fetch(fetchRequest).first
        }
        catch {
            return nil
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
