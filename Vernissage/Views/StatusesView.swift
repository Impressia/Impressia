//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import PixelfedKit

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
                NoDataView(imageSystemName: "photo.on.rectangle.angled", text: "Unfortunately, there are no photos here.")
            } else {
                ScrollView {
                    LazyVStack(alignment: .center) {
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
                        
                        if allItemsLoaded == false {
                            HStack {
                                Spacer()
                                LoadingIndicator()
                                    .task {
                                        do {
                                            try await self.loadMoreStatuses()
                                        } catch {
                                            ErrorService.shared.handle(error, message: "Loading more statuses failed.", showToastr: !Task.isCancelled)
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
                        ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: !Task.isCancelled)
                    }
                }
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadData()
            }
            .padding()
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
            ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: !Task.isCancelled)
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
                remote: false,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit) ?? []
        case .federated:
            return try await self.client.publicTimeline?.getStatuses(
                local: false,
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
            return try await self.client.publicTimeline?.getTagStatuses(
                tag: tag,
                local: false,
                remote: true,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit) ?? []
        }
    }
    
    private func getTitle() -> String {
        switch self.listType {
        case .local:
            return "Local"
        case .federated:
            return "Federeted"
        case .favourites:
            return "Favourites"
        case .bookmarks:
            return "Bookmarks"
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
            ErrorService.shared.handle(error, message: "Error during loading tag from server.", showToastr: false)
        }
    }
    
    private func follow(hashtag: String) async {
        do {
            self.tag = try await self.client.tags?.follow(tag: hashtag)
            ToastrService.shared.showSuccess("You are following the tag.", imageSystemName: "number.square.fill")
        } catch {
            ErrorService.shared.handle(error, message: "Error during following tag.", showToastr: true)
        }
    }
    
    private func unfollow(hashtag: String) async {
        do {
            self.tag = try await self.client.tags?.unfollow(tag: hashtag)
            ToastrService.shared.showSuccess("Tag has been unfollowed.", imageSystemName: "number.square")
        } catch {
            ErrorService.shared.handle(error, message: "Error during unfollowing tag.", showToastr: true)
        }
    }
}
