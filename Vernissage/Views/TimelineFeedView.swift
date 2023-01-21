//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct TimelineFeedView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @State public var accountId: String
    @State public var isLocalOnly: Bool

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
        
        let statuses = try await PublicTimelineService.shared.getStatuses(
            accountData: self.applicationState.accountData,
            local: isLocalOnly,
            remote: !isLocalOnly,
            limit: self.defaultLimit)
        var inPlaceStatuses: [StatusViewModel] = []

        for item in statuses {
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
            let previousStatuses = try await PublicTimelineService.shared.getStatuses(
                accountData: self.applicationState.accountData,
                local: isLocalOnly,
                remote: !isLocalOnly,
                maxId: lastStatusId,
                limit: self.defaultLimit)

            if previousStatuses.count < self.defaultLimit {
                self.allItemsLoaded = true
            }
            
            var inPlaceStatuses: [StatusViewModel] = []
            for item in previousStatuses {
                inPlaceStatuses.append(StatusViewModel(status: item))
            }
            
            self.statusViewModels.append(contentsOf: inPlaceStatuses)
        }
    }
    
    private func loadTopStatuses() async throws {
        if let firstStatusId = self.statusViewModels.first?.id {
            let newestStatuses = try await PublicTimelineService.shared.getStatuses(
                accountData: self.applicationState.accountData,
                local: isLocalOnly,
                remote: !isLocalOnly,
                sinceId: firstStatusId,
                limit: self.defaultLimit)
            
            var inPlaceStatuses: [StatusViewModel] = []
            for item in newestStatuses {
                inPlaceStatuses.append(StatusViewModel(status: item))
            }
            
            self.statusViewModels.insert(contentsOf: inPlaceStatuses, at: 0)
        }
    }
}
