//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

struct UserProfileStatuses: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @State public var accountId: String

    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    
    @State private var statusViewModels: [StatusViewModel] = []
    private let defaultLimit = 20

    var body: some View {
        VStack(alignment: .center) {
            if firstLoadFinished == true {
                ForEach(self.statusViewModels, id: \.id) { item in
                    NavigationLink(destination: StatusView(statusId: item.id,
                                                           imageBlurhash: item.mediaAttachments.first?.blurhash,
                                                           imageWidth: item.getImageWidth(),
                                                           imageHeight: item.getImageHeight())
                        .environmentObject(applicationState)) {
                            ImageRowAsync(statusViewModel: item)
                        }
                        .buttonStyle(EmptyButtonStyle())
                        
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
        let statuses = try await AccountService.shared.getStatuses(
            forAccountId: self.accountId,
            andContext: self.applicationState.accountData,
            limit: self.defaultLimit)
        var inPlaceStatuses: [StatusViewModel] = []

        for item in statuses {
            inPlaceStatuses.append(StatusViewModel(status: item))
        }
        
        self.firstLoadFinished = true
        self.statusViewModels.append(contentsOf: inPlaceStatuses)
        
        if statuses.count < self.defaultLimit {
            self.allItemsLoaded = true
        }
    }
        
    private func loadMoreStatuses() async throws {
        if let lastStatusId = self.statusViewModels.last?.id {
            let previousStatuses = try await AccountService.shared.getStatuses(
                forAccountId: self.accountId,
                andContext: self.applicationState.accountData,
                maxId: lastStatusId,
                limit: self.defaultLimit)

            if previousStatuses.count < self.defaultLimit {
                self.allItemsLoaded = true
            }
            
            var inPlaceStatuses: [StatusViewModel] = []
            for item in previousStatuses {
                inPlaceStatuses.append(StatusViewModel(status: item))
            }
            
            self.statusViewModels.append(contentsOf: inPlaceStatuses)
        }
    }
}

struct UserProfileStatuses_Previews: PreviewProvider {
    static var previews: some View {
        UserProfileStatuses(accountId: "")
    }
}
