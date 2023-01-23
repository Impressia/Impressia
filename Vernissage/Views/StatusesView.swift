//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonKit

struct StatusesView: View {
    public enum ListType {
        case local
        case federated
        case favourites
        case bookmarks
    }
    
    @EnvironmentObject private var applicationState: ApplicationState
    @State public var accountId: String
    @State public var listType: ListType

    @State private var allItemsLoaded = false
    @State private var firstLoadFinished = false
    
    @State private var statusViewModels: [StatusViewModel] = []
    private let defaultLimit = 20

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                if firstLoadFinished == true {
                    ForEach(self.statusViewModels, id: \.uniqueId) { item in
                        NavigationLink(destination: StatusView(statusId: item.id,
                                                               imageBlurhash: item.mediaAttachments.first?.blurhash,
                                                               imageWidth: item.getImageWidth(),
                                                               imageHeight: item.getImageHeight())
                            .environmentObject(applicationState)) {
                                ImageRowAsync(statusViewModel: item)
                            }
                            .buttonStyle(EmptyButtonStyle())
                        
                    }
                    
                    LazyVStack {
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
        .task {
            do {
                try await self.loadStatuses()
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
        var inPlaceStatuses: [StatusViewModel] = []

        for item in statuses.getStatusesWithImagesOnly() {
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
            let previousStatuses = try await self.loadFromApi(maxId: lastStatusId)

            if previousStatuses.count < self.defaultLimit {
                self.allItemsLoaded = true
            }
            
            var inPlaceStatuses: [StatusViewModel] = []
            for item in previousStatuses.getStatusesWithImagesOnly() {
                inPlaceStatuses.append(StatusViewModel(status: item))
            }
            
            self.statusViewModels.append(contentsOf: inPlaceStatuses)
        }
    }
    
    private func loadTopStatuses() async throws {
        if let firstStatusId = self.statusViewModels.first?.id {
            let newestStatuses = try await self.loadFromApi(sinceId: firstStatusId)
            
            var inPlaceStatuses: [StatusViewModel] = []
            for item in newestStatuses.getStatusesWithImagesOnly() {
                inPlaceStatuses.append(StatusViewModel(status: item))
            }
            
            self.statusViewModels.insert(contentsOf: inPlaceStatuses, at: 0)
        }
    }
    
    private func loadFromApi(maxId: String? = nil, sinceId: String? = nil, minId: String? = nil) async throws -> [Status] {
        switch self.listType {
        case .local:
            return try await PublicTimelineService.shared.getStatuses(
                accountData: self.applicationState.accountData,
                local: true,
                remote: false,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit)
        case .federated:
            return try await PublicTimelineService.shared.getStatuses(
                accountData: self.applicationState.accountData,
                local: false,
                remote: true,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit)
        case .favourites:
            return try await AccountService.shared.favourites(
                accountData: self.applicationState.accountData,
                maxId: maxId,
                sinceId: sinceId,
                minId: minId,
                limit: self.defaultLimit)
        case .bookmarks:
            return try await AccountService.shared.bookmarks(
                accountData: self.applicationState.accountData,
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
        }
    }
}
