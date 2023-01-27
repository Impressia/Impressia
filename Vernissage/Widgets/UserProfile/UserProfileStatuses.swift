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
        LazyVStack(alignment: .center) {
            if firstLoadFinished == true {
                ForEach(self.statusViewModels, id: \.id) { item in
                    NavigationLink(value: RouteurDestinations.status(
                        id: item.id,
                        blurhash: item.mediaAttachments.first?.blurhash,
                        highestImageUrl: item.mediaAttachments.getHighestImage()?.url,
                        metaImageWidth: item.getImageWidth(),
                        metaImageHeight: item.getImageHeight())
                    ) {
                        ImageRowAsync(statusViewModel: item)
                    }
                    .buttonStyle(EmptyButtonStyle())
                }

                if allItemsLoaded == false && firstLoadFinished == true {
                    HStack {
                        Spacer()
                        LoadingIndicator()
                            .task {
                                do {
                                    try await self.loadMoreStatuses()
                                } catch {
                                    ErrorService.shared.handle(error, message: "Loading more statuses failed.", showToastr: true)
                                }
                            }
                        Spacer()
                    }
                }
            } else {
                LoadingIndicator()
            }
        }.task {
            do {
                try await self.loadStatuses()
            } catch {
                ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: !Task.isCancelled)
            }
        }
    }
    
    private func loadStatuses() async throws {
        guard firstLoadFinished == false else {
            return
        }
        
        let statuses = try await AccountService.shared.statuses(
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
            let previousStatuses = try await AccountService.shared.statuses(
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

