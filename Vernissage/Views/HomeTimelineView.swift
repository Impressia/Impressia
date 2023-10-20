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

@MainActor
struct HomeTimelineView: View {
    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client
    @Environment(\.modelContext) private var modelContext

    @State private var allItemsLoaded = false
    @State private var statusViewModels: [StatusModel] = []
    @State private var state: ViewState = .loading
    @State private var lastStatusId: String?

    @State private var opacity = 0.0
    @State private var offset = -50.0
    
    private let defaultLimit = 80
    private let imagePrefetcher = ImagePrefetcher(destination: .diskCache)

    var body: some View {
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
        ZStack {
            ScrollView {
                LazyVStack(alignment: .center) {
                    ForEach(self.statusViewModels, id: \.id) { item in
                        if self.shouldUpToDateBeVisible(statusId: item.id) {
                            self.upToDatePlaceholder()
                        }
                        
                        ImageRowAsync(statusViewModel: item, containerWidth: Binding.constant(UIScreen.main.bounds.width))
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
            
            self.newPhotosView()
                .offset(y: self.offset)
                .opacity(self.opacity)
        }
        .refreshable {
            do {
                HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.3))
                try await self.refreshStatuses()
                HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.7))
            } catch {
                ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
            }
        }
        .onChange(of: self.applicationState.showReboostedStatuses) {
            Task {
                do {
                    HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.3))
                    try await self.refreshStatuses()
                    HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.7))
                } catch {
                    ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
                }
            }
        }
        .onChange(of: self.applicationState.amountOfNewStatuses) {
            self.calculateOffset()
        }.onAppear {
            self.calculateOffset()
        }
    }
    
    @ViewBuilder
    private func upToDatePlaceholder() -> some View {
        VStack(alignment: .center) {
            Image(systemName: "checkmark.seal")
                .resizable()
                .frame(width: 64, height: 64)
                .fontWeight(.ultraLight)
                .foregroundColor(self.applicationState.tintColor.color().opacity(0.6))
            Text("home.title.allCaughtUp", comment: "You're all caught up")
                .font(.title2)
                .fontWeight(.thin)
                .foregroundColor(Color.mainTextColor.opacity(0.6))
        }
        .padding(.vertical, 8)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.75)
    }
    
    @ViewBuilder
    private func newPhotosView() -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                Spacer()

                HStack {
                    Image(systemName: "arrow.up")
                        .fontWeight(.light)
                    Text("\(self.applicationState.amountOfNewStatuses)")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
                .font(.callout)
                .foregroundColor(Color.mainTextColor)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.top, 10)
        .padding(.trailing, 6)
    }

    private func loadData() async {
        do {
            try await self.loadFirstStatuses()
            try ViewedStatusHandler.shared.deleteOldViewedStatuses(modelContext: modelContext)

            self.state = .loaded
        } catch {
            ErrorService.shared.handle(error, message: "statuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
            self.state = .error(error)
        }
    }

    private func loadFirstStatuses() async throws {
        guard let accountId = self.applicationState.account?.id else {
            return
        }
        
        // Download statuses from API.
        let statuses = try await self.loadFromApi()

        if statuses.isEmpty {
            self.allItemsLoaded = true
            return
        }

        // Remember last status id returned by API.
        self.lastStatusId = statuses.last?.id
        
        // Get only visible statuses.
        let visibleStatuses = HomeTimelineService.shared.getVisibleStatuses(accountId: accountId,
                                                                            statuses: statuses,
                                                                            hideStatusesWithoutAlt: self.applicationState.hideStatusesWithoutAlt,
                                                                            modelContext: modelContext)
        
        // Remeber first status returned by API in user context (when it's newer then remembered).
        try AccountDataHandler.shared.update(lastSeenStatusId: nil, lastLoadedStatusId: statuses.first?.id, accountId: accountId, modelContext: modelContext)
        
        // Append statuses to viewed.
        try ViewedStatusHandler.shared.append(contentsOf: statuses, accountId: accountId, modelContext: modelContext)
        
        // Map to view models.
        let statusModels = visibleStatuses.map({ StatusModel(status: $0) })
        
        // Prefetch images.
        self.prefetch(statusModels: statusModels)

        // Append to empty list.
        self.statusViewModels.append(contentsOf: statusModels)
    }

    private func loadMoreStatuses() async throws {
        if let lastStatusId = self.lastStatusId, let accountId = self.applicationState.account?.id  {
            
            // Download statuses from API.
            let statuses = try await self.loadFromApi(maxId: lastStatusId)

            if statuses.isEmpty {
                self.allItemsLoaded = true
                return
            }

            // Now we have new last status.
            if let lastStatusId = statuses.last?.id {
                self.lastStatusId = lastStatusId
            }

            // Get only visible statuses.
            let visibleStatuses = HomeTimelineService.shared.getVisibleStatuses(accountId: accountId,
                                                                                statuses: statuses,
                                                                                hideStatusesWithoutAlt: self.applicationState.hideStatusesWithoutAlt,
                                                                                modelContext: modelContext)
            
            // Append statuses to viewed.
            try ViewedStatusHandler.shared.append(contentsOf: statuses, accountId: accountId, modelContext: modelContext)
            
            // Map to view models.
            let statusModels = visibleStatuses.map({ StatusModel(status: $0) })

            // Prefetch images.
            self.prefetch(statusModels: statusModels)

            // Append statuses to existing array of statuses (at the end).
            self.statusViewModels.append(contentsOf: statusModels)
        }
    }

    private func refreshStatuses() async throws {
        guard let accountId = self.applicationState.account?.id else {
            return
        }
        
        // Download statuses from API.
        let statuses = try await self.loadFromApi()

        if statuses.isEmpty {
            self.allItemsLoaded = true
            return
        }

        // Remember last status id returned by API.
        self.lastStatusId = statuses.last?.id
        
        // Get only visible statuses.
        let visibleStatuses = HomeTimelineService.shared.getVisibleStatuses(accountId: accountId,
                                                                            statuses: statuses,
                                                                            hideStatusesWithoutAlt: self.applicationState.hideStatusesWithoutAlt,
                                                                            modelContext: modelContext)

        // Remeber first status returned by API in user context (when it's newer then remembered).
        try AccountDataHandler.shared.update(lastSeenStatusId: self.statusViewModels.first?.id, lastLoadedStatusId: statuses.first?.id, accountId: accountId, modelContext: modelContext)
        
        // Append statuses to viewed.
        try ViewedStatusHandler.shared.append(contentsOf: statuses, accountId: accountId, modelContext: modelContext)
        
        // Map to view models.
        let statusModels = visibleStatuses.map({ StatusModel(status: $0) })
        
        // Prefetch images.
        self.prefetch(statusModels: statusModels)

        // Replace old collection with new one.
        self.statusViewModels = statusModels
    }

    private func loadFromApi(maxId: String? = nil, sinceId: String? = nil, minId: String? = nil) async throws -> [Status] {
        return try await self.client.publicTimeline?.getHomeTimeline(
            maxId: maxId,
            sinceId: sinceId,
            minId: minId,
            limit: self.defaultLimit,
            includeReblogs: self.applicationState.showReboostedStatuses) ?? []
    }

    private func calculateOffset() {
        if self.applicationState.amountOfNewStatuses > 0 {
            withAnimation(.easeIn) {
                self.showNewStatusesView()
            }
        } else {
            withAnimation(.easeOut) {
                self.hideNewStatusesView()
            }
        }
    }

    private func showNewStatusesView() {
        self.offset = 0.0
        self.opacity = 1.0
    }

    private func hideNewStatusesView() {
        self.offset = -50.0
        self.opacity = 0.0
    }
    
    private func prefetch(statusModels: [StatusModel]) {
        imagePrefetcher.startPrefetching(with: statusModels.getAllImagesUrls())
    }
    
    private func shouldHideStatusWithoutAlt(status: Status) -> Bool {
        if self.applicationState.hideStatusesWithoutAlt == false {
            return false
        }
        
        return status.statusContainsAltText() == false
    }
    
    private func shouldUpToDateBeVisible(statusId: String) -> Bool {
        return self.applicationState.lastSeenStatusId != statusViewModels.first?.id && self.applicationState.lastSeenStatusId == statusId
    }
}
