//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct StatusesView: View {
    public enum ListType: Hashable {
        case local
        case federated
        case favourites
        case bookmarks
        case hashtag(tag: String)
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

    private let defaultLimit = 20

    var body: some View {
        self.mainBody()
            .navigationTitle(self.getTitle())
            .toolbar {
                // TODO: It seems like pixelfed is not supporting the endpoints.
                // self.getTrailingToolbar()
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
            LazyVStack(alignment: .center) {
                ForEach(self.statusViewModels, id: \.id) { item in
                    ImageRowAsync(statusViewModel: item)
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
        .refreshable {
            do {
                HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.3))
                try await self.loadTopStatuses()
                HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.7))
            } catch {
                ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
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

        var inPlaceStatuses: [StatusModel] = []
        for item in statuses.getStatusesWithImagesOnly() {
            inPlaceStatuses.append(StatusModel(status: item))
        }

        self.statusViewModels.append(contentsOf: inPlaceStatuses)
    }

    private func loadMoreStatuses() async throws {
        if let lastStatusId = self.statusViewModels.last?.id {
            let previousStatuses = try await self.loadFromApi(maxId: lastStatusId)

            if previousStatuses.isEmpty {
                self.allItemsLoaded = true
                return
            }

            var inPlaceStatuses: [StatusModel] = []
            for item in previousStatuses.getStatusesWithImagesOnly() {
                inPlaceStatuses.append(StatusModel(status: item))
            }

            self.statusViewModels.append(contentsOf: inPlaceStatuses)
        }
    }

    private func loadTopStatuses() async throws {
        if let firstStatusId = self.statusViewModels.first?.id {
            let newestStatuses = try await self.loadFromApi(sinceId: firstStatusId)

            var inPlaceStatuses: [StatusModel] = []
            for item in newestStatuses.getStatusesWithImagesOnly() {
                inPlaceStatuses.append(StatusModel(status: item))
            }

            self.statusViewModels.insert(contentsOf: inPlaceStatuses, at: 0)
        }
    }

    private func loadFromApi(maxId: String? = nil, sinceId: String? = nil, minId: String? = nil) async throws -> [Status] {
        switch self.listType {
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

    private func getTitle() -> LocalizedStringKey {
        switch self.listType {
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

    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        if case .hashtag(let hashtag) = self.listType {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        if self.tag?.following == true {
                            await self.follow(hashtag: hashtag)
                        } else {
                            await self.unfollow(hashtag: hashtag)
                        }
                    }
                } label: {
                    Image(systemName: self.tag?.following == true ? "number.square.fill" : "number.square")
                        .tint(.mainTextColor)
                }
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
}
