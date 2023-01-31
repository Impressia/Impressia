//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonKit

struct StatusesView: View {
    public enum ListType: Hashable {
        case local
        case federated
        case favourites
        case bookmarks
        case hashtag(tag: String)
    }
    
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var routerPath: RouterPath

    @State public var listType: ListType

    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    
    @State private var tag: Tag?
    @State private var statusViewModels: [StatusModel] = []
    private let defaultLimit = 20

    var body: some View {
        ScrollView {
            if firstLoadFinished == true {
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
                }
            }
        }
        .navigationBarTitle(self.getTitle())
        .overlay(alignment: .center) {
            if firstLoadFinished == false {
                LoadingIndicator()
            } else {
                if self.statusViewModels.isEmpty {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .padding(.bottom, 4)
                        Text("Unfortunately, there are no photos here.")
                            .font(.title3)
                    }.foregroundColor(.lightGrayColor)
                }
            }
        }
        .toolbar {
            // TODO: It seems like pixelfed is not supporting the endpoints.
            // self.getTrailingToolbar()
        }
        .onFirstAppear {
            do {
                try await self.loadStatuses()

                if case .hashtag(let hashtag) = self.listType {
                    await self.loadTag(hashtag: hashtag)
                }
            } catch {
                ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: !Task.isCancelled)
            }
        }.refreshable {
            do {
                try await self.loadTopStatuses()
            } catch {
                ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: !Task.isCancelled)
            }
        }
    }
    
    private func loadStatuses() async throws {
        guard firstLoadFinished == false else {
            return
        }
        
        let statuses = try await self.loadFromApi()
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
            let previousStatuses = try await self.loadFromApi(maxId: lastStatusId)

            if previousStatuses.count < self.defaultLimit {
                self.allItemsLoaded = true
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
            return try await PublicTimelineService.shared.getStatuses(
                for: self.applicationState.account,
                local: true,
                remote: false,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit)
        case .federated:
            return try await PublicTimelineService.shared.getStatuses(
                for: self.applicationState.account,
                local: false,
                remote: true,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit)
        case .favourites:
            return try await AccountService.shared.favourites(
                for: self.applicationState.account,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit)
        case .bookmarks:
            return try await AccountService.shared.bookmarks(
                for: self.applicationState.account,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit)
        case .hashtag(let tag):
            return try await PublicTimelineService.shared.getTagStatuses(
                for: self.applicationState.account,
                tag: tag,
                local: false,
                remote: true,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit)
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
            self.tag = try await TagsService.shared.get(tag: hashtag, for: self.applicationState.account)
        } catch {
            ErrorService.shared.handle(error, message: "Error during loading tag from server.", showToastr: false)
        }
    }
    
    private func follow(hashtag: String) async {
        do {
            self.tag = try await TagsService.shared.follow(tag: hashtag, for: self.applicationState.account)
            ToastrService.shared.showSuccess("You are following the tag.", imageSystemName: "number.square.fill")
        } catch {
            ErrorService.shared.handle(error, message: "Error during following tag.", showToastr: true)
        }
    }
    
    private func unfollow(hashtag: String) async {
        do {
            self.tag = try await TagsService.shared.unfollow(tag: hashtag, for: self.applicationState.account)
            ToastrService.shared.showSuccess("Tag has been unfollowed.", imageSystemName: "number.square")
        } catch {
            ErrorService.shared.handle(error, message: "Error during unfollowing tag.", showToastr: true)
        }
    }
}
