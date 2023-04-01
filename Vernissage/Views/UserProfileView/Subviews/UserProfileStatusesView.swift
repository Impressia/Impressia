//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit

struct UserProfileStatusesView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client

    @State public var accountId: String

    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    @State private var statusViewModels: [StatusModel] = []
    private let defaultLimit = 20

    var body: some View {
        LazyVStack(alignment: .center) {
            if firstLoadFinished == true {
                ForEach(self.statusViewModels, id: \.id) { item in
                    ImageRowAsync(statusViewModel: item)
                }

                if allItemsLoaded == false && firstLoadFinished == true {
                    HStack {
                        Spacer()
                        LoadingIndicator()
                            .task {
                                do {
                                    try await self.loadMoreStatuses()
                                } catch {
                                    ErrorService.shared.handle(error, message: "global.error.errorDuringDownloadStatuses", showToastr: true)
                                }
                            }
                        Spacer()
                    }
                }
            } else {
                LoadingIndicator()
            }
        }
        .onFirstAppear {
            do {
                try await self.loadStatuses()
            } catch {
                ErrorService.shared.handle(error, message: "global.error.errorDuringDownloadStatuses", showToastr: !Task.isCancelled)
            }
        }
    }

    private func loadStatuses() async throws {
        let statuses = try await self.client.accounts?.statuses(createdBy: self.accountId, limit: self.defaultLimit) ?? []
        var inPlaceStatuses: [StatusModel] = []

        for item in statuses.getStatusesWithImagesOnly() {
            inPlaceStatuses.append(StatusModel(status: item))
        }

        self.firstLoadFinished = true
        self.statusViewModels.append(contentsOf: inPlaceStatuses)

        if statuses.count < self.defaultLimit {
            self.allItemsLoaded = true
        }
    }

    private func loadMoreStatuses() async throws {
        if let lastStatusId = self.statusViewModels.last?.id {
            let previousStatuses = try await self.client.accounts?.statuses(createdBy: self.accountId, maxId: lastStatusId, limit: self.defaultLimit) ?? []

            if previousStatuses.isEmpty {
                self.allItemsLoaded = true
            }

            var inPlaceStatuses: [StatusModel] = []
            for item in previousStatuses.getStatusesWithImagesOnly() {
                inPlaceStatuses.append(StatusModel(status: item))
            }

            self.statusViewModels.append(contentsOf: inPlaceStatuses)
        }
    }
}
