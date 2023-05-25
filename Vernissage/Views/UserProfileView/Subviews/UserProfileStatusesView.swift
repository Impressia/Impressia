//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Nuke
import PixelfedKit
import ClientKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct UserProfileStatusesView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client

    @State public var accountId: String

    // Gallery parameters.
    @Binding private var imageColumns: Int
    @Binding private var containerWidth: Double
    @Binding private var containerHeight: Double

    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    @State private var statusViewModels: [StatusModel] = []

    private let defaultLimit = 40
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)
    private let singleGrids = [GridItem(.flexible(), spacing: 10)]
    private let dubleGrid = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 0)]

    init(accountId: String, imageColumns: Binding<Int>, containerWidth: Binding<Double>, containerHeight: Binding<Double>) {
        self.accountId = accountId
        self._imageColumns = imageColumns
        self._containerWidth = containerWidth
        self._containerHeight = containerHeight
    }

    var body: some View {
        if firstLoadFinished == true {
            if self.imageColumns > 1 {
                WaterfallGrid(statusViewModel: $statusViewModels, columns: $imageColumns, hideLoadMore: $allItemsLoaded) { item in
                    ImageRowAsync(statusViewModel: item, withAvatar: false, containerWidth: $containerWidth)
                } onLoadMore: {
                    do {
                        try await self.loadMoreStatuses()
                    } catch {
                        ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
                    }
                }
            } else {
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            self.applicationState.showGridOnUserProfile = false
                            ApplicationSettingsHandler.shared.set(showGridOnUserProfile: false)
                        }
                    } label: {
                        Image(systemName: "rectangle.grid.1x2.fill")
                            .foregroundColor(self.applicationState.showGridOnUserProfile ? .lightGrayColor : .accentColor)
                            .padding(.trailing, 8)
                            .padding(.bottom, 8)
                    }
                    Button {
                        withAnimation {
                            self.applicationState.showGridOnUserProfile = true
                            ApplicationSettingsHandler.shared.set(showGridOnUserProfile: true)
                        }
                    } label: {
                        Image(systemName: "rectangle.grid.2x2.fill")
                            .foregroundColor(self.applicationState.showGridOnUserProfile ? .accentColor : .lightGrayColor)
                            .padding(.trailing, 16)
                            .padding(.bottom, 8)
                    }
                }

                LazyVGrid(columns: self.applicationState.showGridOnUserProfile ? dubleGrid : singleGrids, spacing: 5) {
                    ForEach(self.statusViewModels, id: \.id) { item in
                        ImageRowAsync(statusViewModel: item,
                                      withAvatar: false,
                                      containerWidth: Binding.constant(self.applicationState.showGridOnUserProfile ? self.containerWidth / 2 : self.containerWidth),
                                      clipToRectangle: $applicationState.showGridOnUserProfile)
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
                }
            }
        } else {
            LoadingIndicator()
                .onFirstAppear {
                    do {
                        try await self.loadStatuses()
                    } catch {
                        ErrorService.shared.handle(error, message: "global.error.errorDuringDownloadStatuses", showToastr: !Task.isCancelled)
                    }
                }
        }
    }

    private func loadStatuses() async throws {
        let statuses = try await self.client.accounts?.statuses(createdBy: self.accountId, limit: self.defaultLimit) ?? []
        var inPlaceStatuses: [StatusModel] = []

        for item in statuses.getStatusesWithImagesOnly() {
            inPlaceStatuses.append(StatusModel(status: item))
        }

        // Prefetch images.
        self.prefetch(statusModels: inPlaceStatuses)

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

            // Prefetch images.
            self.prefetch(statusModels: inPlaceStatuses)

            self.statusViewModels.append(contentsOf: inPlaceStatuses)
        }
    }

    private func prefetch(statusModels: [StatusModel]) {
        imagePrefetcher.startPrefetching(with: statusModels.getAllImagesUrls())
    }
}
