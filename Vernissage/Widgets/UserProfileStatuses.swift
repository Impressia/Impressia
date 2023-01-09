//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonSwift

struct UserProfileStatuses: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @State public var accountId: String

    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    
    @State private var statuses: [Status] = []

    var body: some View {
        VStack {
            if firstLoadFinished == true {
                ForEach(self.statuses, id: \.id) { item in
                    NavigationLink(destination: StatusView(statusId: item.id)
                        .environmentObject(applicationState)) {
                            ImageRowAsync(attachments: item.mediaAttachments)
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
        }.onAppear {
            Task {
                do {
                    try await self.loadStatuses()
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func loadStatuses() async throws {
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

struct UserProfileStatuses_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileStatuses(accountId: "")
    }
}
