//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import PixelfedKit

struct PaginableStatusesView: View {
    public enum ListType: Hashable {
        case favourites
        case bookmarks
    }
    
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    @EnvironmentObject private var routerPath: RouterPath

    @State public var listType: ListType

    @State private var allItemsLoaded = false
    @State private var statusViewModels: [StatusModel] = []
    @State private var state: ViewState = .loading
    @State private var page = 1
    
    private let defaultLimit = 10

    var body: some View {
        self.mainBody()
            .navigationBarTitle(self.getTitle())
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
    
    private func loadData() async {
        do {
            try await self.loadStatuses()
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
        
        // TODO: It seems that paging is not supported and we cannot download additiona data.
        self.allItemsLoaded = true
                
        var inPlaceStatuses: [StatusModel] = []
        for item in statuses.getStatusesWithImagesOnly() {
            inPlaceStatuses.append(StatusModel(status: item))
        }
        
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
    
    private func getTitle() -> String {
        switch self.listType {
        case .favourites:
            return "Favourites"
        case .bookmarks:
            return "Bookmarks"
        }
    }
}
