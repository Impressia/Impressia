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

struct StatusesView: View {
    public enum ListType: Hashable {
        case home
        case local
        case federated
        case favourites
        case bookmarks
        case hashtag(tag: String)

        public var title: LocalizedStringKey {
            switch self {
            case .home:
                return "mainview.tab.homeTimeline"
            case .local:
                return "statuses.navigationBar.localTimeline"
            case .federated:
                return "statuses.navigationBar.federatedTimeline"
            case .favourites:
                return "statuses.navigationBar.favourites"
            case .bookmarks:
                return "statuses.navigationBar.bookmarks"
            case .hashtag(let tag):
                return "#\(tag)"
            }
        }
    }

    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    @EnvironmentObject private var routerPath: RouterPath

    @Environment(\.dismiss) private var dismiss

    @State public var listType: ListType

    @State private var allItemsLoaded = false
    @State private var tag: Tag?
    @State private var statusViewModels: [StatusModel] = []
    @State private var state: ViewState = .loading
    @State private var lastStatusId: String?
    @State private var waterfallId: String = String.randomString(length: 8)

    // Gallery parameters.
    @State private var imageColumns = 3
    @State private var containerWidth: Double = UIDevice.isIPad ? UIScreen.main.bounds.width / 3 : UIScreen.main.bounds.width
    @State private var containerHeight: Double = UIDevice.isIPad ? UIScreen.main.bounds.height / 3 : UIScreen.main.bounds.height

    private let defaultLimit = 40
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)

    var body: some View {
        self.mainBody()
            .navigationTitle(self.listType.title)
            .toolbar {
                 self.getTrailingToolbar()
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
            if self.statusViewModels.isEmpty {
                NoDataView(imageSystemName: "photo.on.rectangle.angled", text: "statuses.title.noPhotos")
            } else {
                self.list()
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadData()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func list() -> some View {
        ScrollView {
            if self.imageColumns > 1 {
                WaterfallGrid($statusViewModels, refreshId: $waterfallId, columns: $imageColumns, hideLoadMore: $allItemsLoaded) { item in
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
        .refreshable {
            do {
                HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.3))
                try await self.loadTopStatuses()
                HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.7))
            } catch {
                ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
            }
        }
        .onChange(of: self.applicationState.showReboostedStatuses) { _ in
            if self.listType != .home {
                return
            }

            Task { @MainActor in
                HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.3))
                try await self.loadTopStatuses()
                HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.7))
            }
        }
    }

    private func loadData() async {
        do {
            try await self.loadStatuses()

            if case .hashtag(let hashtag) = self.listType {
                await self.loadTag(hashtag: hashtag)
            }

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

        // Remember last status id returned by API.
        self.lastStatusId = statuses.last?.id

        // Get only statuses with images.
        var inPlaceStatuses: [StatusModel] = []
        for item in statuses.getStatusesWithImagesOnly() {
            // We have to skip statuses that are boosted from muted accounts.
            if let accountId = self.applicationState.account?.id, AccountRelationshipHandler.shared.isBoostedStatusesMuted(accountId: accountId, status: item) {
                continue
            }
            
            inPlaceStatuses.append(StatusModel(status: item))
        }

        // Prefetch images.
        self.prefetch(statusModels: inPlaceStatuses)

        // Append to empty list.
        self.statusViewModels.append(contentsOf: inPlaceStatuses)
    }

    private func loadMoreStatuses() async throws {
        if let lastStatusId = self.lastStatusId {
            let previousStatuses = try await self.loadFromApi(maxId: lastStatusId)

            if previousStatuses.isEmpty {
                self.allItemsLoaded = true
                return
            }

            // Now we have new last status.
            if let lastStatusId = previousStatuses.last?.id {
                self.lastStatusId = lastStatusId
            }

            // Get only statuses with images.
            var inPlaceStatuses: [StatusModel] = []
            for item in previousStatuses.getStatusesWithImagesOnly() {
                // We have to skip statuses that are boosted from muted accounts.
                if let accountId = self.applicationState.account?.id, AccountRelationshipHandler.shared.isBoostedStatusesMuted(accountId: accountId, status: item) {
                    continue
                }

                inPlaceStatuses.append(StatusModel(status: item))
            }

            // Prefetch images.
            self.prefetch(statusModels: inPlaceStatuses)

            // Append statuses to existing array of statuses (at the end).
            self.statusViewModels.append(contentsOf: inPlaceStatuses)
        }
    }

    private func loadTopStatuses() async throws {
        let statuses = try await self.loadFromApi()

        if statuses.isEmpty {
            self.allItemsLoaded = true
            return
        }

        // Remember last status id returned by API.
        self.lastStatusId = statuses.last?.id

        // Get only statuses with images.
        var inPlaceStatuses: [StatusModel] = []
        for item in statuses.getStatusesWithImagesOnly() {
            // We have to skip statuses that are boosted from muted accounts.
            if let accountId = self.applicationState.account?.id, AccountRelationshipHandler.shared.isBoostedStatusesMuted(accountId: accountId, status: item) {
                continue
            }

            inPlaceStatuses.append(StatusModel(status: item))
        }
        
        // Prefetch images.
        self.prefetch(statusModels: inPlaceStatuses)

        // Replace old collection with new one.
        self.waterfallId = String.randomString(length: 8)
        self.statusViewModels = inPlaceStatuses
    }

    private func loadFromApi(maxId: String? = nil, sinceId: String? = nil, minId: String? = nil) async throws -> [Status] {
        switch self.listType {
        case .home:
            return try await self.client.publicTimeline?.getHomeTimeline(
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit,
                includeReblogs: self.applicationState.showReboostedStatuses) ?? []
        case .local:
            return try await self.client.publicTimeline?.getStatuses(
                local: true,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit) ?? []
        case .federated:
            return try await self.client.publicTimeline?.getStatuses(
                remote: true,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit) ?? []
        case .favourites:
            return try await self.client.accounts?.favourites(
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit) ?? []
        case .bookmarks:
            return try await self.client.accounts?.bookmarks(
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit) ?? []
        case .hashtag(let tag):
            let hashtagsFromApi = try await self.client.search?.search(query: tag, resultsType: .hashtags)
            guard let hashtagsFromApi = hashtagsFromApi, hashtagsFromApi.hashtags.isEmpty == false else {
                ToastrService.shared.showError(title: "global.error.hashtagNotExists", imageSystemName: "exclamationmark.octagon")
                dismiss()

                return []
            }

            return try await self.client.publicTimeline?.getTagStatuses(
                tag: tag,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit) ?? []
        }
    }

    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        if case .hashtag(let hashtag) = self.listType {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        if self.tag?.following == true {
                            await self.unfollow(hashtag: hashtag)
                        } else {
                            await self.follow(hashtag: hashtag)
                        }
                    }
                } label: {
                    Image(systemName: self.tag?.following == true ? "number.square.fill" : "number.square")
                        .tint(.mainTextColor)
                }
                .disabled(self.tag == nil)
            }
        }
    }

    private func loadTag(hashtag: String) async {
        do {
            self.tag = try await self.client.tags?.get(tag: hashtag)
        } catch {
            ErrorService.shared.handle(error, message: "global.error.errorDuringDownloadHashtag", showToastr: false)
        }
    }

    private func follow(hashtag: String) async {
        do {
            self.tag = try await self.client.tags?.follow(tag: hashtag)
            ToastrService.shared.showSuccess("statuses.title.tagFollowed", imageSystemName: "number.square.fill")
        } catch {
            ErrorService.shared.handle(error, message: "statuses.error.tagFollowFailed", showToastr: true)
        }
    }

    private func unfollow(hashtag: String) async {
        do {
            self.tag = try await self.client.tags?.unfollow(tag: hashtag)
            ToastrService.shared.showSuccess("statuses.title.tagUnfollowed", imageSystemName: "number.square")
        } catch {
            ErrorService.shared.handle(error, message: "statuses.error.tagUnfollowFailed", showToastr: true)
        }
    }

    private func prefetch(statusModels: [StatusModel]) {
        imagePrefetcher.startPrefetching(with: statusModels.getAllImagesUrls())
    }
}
