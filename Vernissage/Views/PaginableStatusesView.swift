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

struct PaginableStatusesView: View {
    public enum ListType: Hashable {
        case favourites
        case bookmarks

        public var title: LocalizedStringKey {
            switch self {
            case .favourites:
                return "statuses.navigationBar.favourites"
            case .bookmarks:
                return "statuses.navigationBar.bookmarks"
            }
        }
    }

    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    @EnvironmentObject private var routerPath: RouterPath

    @State public var listType: ListType

    @State private var allItemsLoaded = false
    @State private var statusViewModels: [StatusModel] = []
    @State private var state: ViewState = .loading
    @State private var page = 1

    // Gallery parameters.
    @State private var imageColumns = 3
    @State private var containerWidth: Double = UIScreen.main.bounds.width
    @State private var containerHeight: Double = UIScreen.main.bounds.height

    private let defaultLimit = 10
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)

    var body: some View {
        self.mainBody()
            .navigationTitle(self.listType.title)
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
            if self.statusViewModels.isEmpty {
                NoDataView(imageSystemName: "photo.on.rectangle.angled", text: "statuses.title.noPhotos")
            } else {
                self.list()
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                self.page = 1
                self.allItemsLoaded = false

                await self.loadData()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func list() -> some View {
        ScrollView {
            if self.imageColumns > 1 {
                WaterfallGrid($statusViewModels, columns: $imageColumns, hideLoadMore: $allItemsLoaded) { item in
                    ImageRowAsync(statusViewModel: item, containerWidth: $containerWidth)
                } onLoadMore: {
                    do {
                        try await self.loadMoreStatuses()
                    } catch {
                        ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
                    }
                }
            } else {
                LazyVStack(alignment: .center) {
                    ForEach(self.statusViewModels, id: \.id) { item in
                        ImageRowAsync(statusViewModel: item, containerWidth: $containerWidth)
                    }

                    if allItemsLoaded == false {
                        HStack {
                            Spacer()
                            LoadingIndicator()
                                .task {
                                    do {
                                        try await self.loadMoreStatuses()
                                    } catch {
                                        ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
                                    }
                                }
                            Spacer()
                        }
                    }
                }
            }
        }
        .gallery { galleryProperties in
            self.imageColumns = galleryProperties.imageColumns
            self.containerWidth = galleryProperties.containerWidth
            self.containerHeight = galleryProperties.containerHeight
        }
    }

    private func loadData() async {
        do {
            try await self.loadStatuses()
            self.state = .loaded
        } catch {
            ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
            self.state = .error(error)
        }
    }

    private func loadStatuses() async throws {
        let statuses = try await self.loadFromApi()

        if statuses.isEmpty {
            self.allItemsLoaded = true
            return
        }

        // TODO: It seems that paging is not supported and we cannot download additiona data.
        self.allItemsLoaded = true

        var inPlaceStatuses: [StatusModel] = []
        for item in statuses.getStatusesWithImagesOnly() {
            inPlaceStatuses.append(StatusModel(status: item))
        }

        // Prefetch images.
        self.prefetch(statusModels: inPlaceStatuses)

        self.statusViewModels.append(contentsOf: inPlaceStatuses)
    }

    private func loadMoreStatuses() async throws {
        self.page = self.page + 1

        let previousStatuses = try await self.loadFromApi()

        if previousStatuses.isEmpty {
            self.allItemsLoaded = true
            return
        }

        var inPlaceStatuses: [StatusModel] = []
        for item in previousStatuses.getStatusesWithImagesOnly() {
            inPlaceStatuses.append(StatusModel(status: item))
        }

        // Prefetch images.
        self.prefetch(statusModels: inPlaceStatuses)

        self.statusViewModels.append(contentsOf: inPlaceStatuses)
    }

    private func loadFromApi() async throws -> [Status] {
        switch self.listType {

        case .favourites:
            return try await self.client.accounts?.favourites(limit: self.defaultLimit, page: self.page) ?? []
        case .bookmarks:
            return try await self.client.accounts?.bookmarks(limit: self.defaultLimit, page: self.page) ?? []
        }
    }

    private func prefetch(statusModels: [StatusModel]) {
        imagePrefetcher.startPrefetching(with: statusModels.getAllImagesUrls())
    }
}
