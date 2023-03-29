//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
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
            .navigationTitle(self.getTitle())
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
    
    private func getTitle() -> LocalizedStringKey {
        switch self.listType {
        case .favourites:
            return "statuses.navigationBar.favourites"
        case .bookmarks:
            return "statuses.navigationBar.bookmarks"
        }
    }
}
