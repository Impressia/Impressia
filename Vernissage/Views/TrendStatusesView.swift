//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit

struct TrendStatusesView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client

    @State public var accountId: String

    @State private var tabSelectedValue: Pixelfed.Trends.TrendRange = .daily
    @State private var statusViewModels: [StatusModel] = []
    @State private var state: ViewState = .loading

    var body: some View {
        ScrollView {
            Picker(selection: $tabSelectedValue, label: Text("")) {
                Text("trendingStatuses.title.daily", comment: "Daily").tag(Pixelfed.Trends.TrendRange.daily)
                Text("trendingStatuses.title.monthly", comment: "Monthly").tag(Pixelfed.Trends.TrendRange.monthly)
                Text("trendingStatuses.title.yearly", comment: "Yearly").tag(Pixelfed.Trends.TrendRange.yearly)

            }
            .padding()
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: tabSelectedValue) { _ in
                Task {
                    do {
                        self.state = .loading
                        self.statusViewModels = []
                        try await self.loadStatuses()
                    } catch {
                        ErrorService.shared.handle(error, message: "trendingStatuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
                    }
                }
            }

            self.mainBody()
        }
        .navigationTitle("trendingStatuses.navigationBar.title")
    }

    @ViewBuilder
    private func mainBody() -> some View {
        switch state {
        case .loading:
            LoadingIndicator()
                .task {
                    do {
                        try await self.loadStatuses()
                        self.state = .loaded
                    } catch {
                        if !Task.isCancelled {
                            ErrorService.shared.handle(error, message: "trendingStatuses.error.loadingStatusesFailed", showToastr: true)
                            self.state = .error(error)
                        } else {
                            ErrorService.shared.handle(error, message: "trendingStatuses.error.loadingStatusesFailed", showToastr: false)
                        }
                    }
                }
        case .loaded:
            if self.statusViewModels.isEmpty {
                NoDataView(imageSystemName: "photo.on.rectangle.angled", text: "trendingStatuses.title.noPhotos")
            } else {
                LazyVStack(alignment: .center) {
                    ForEach(self.statusViewModels, id: \.id) { item in
                        ImageRowAsync(statusViewModel: item)
                    }
                }
                .refreshable {
                    do {
                        HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.3))
                        try await self.loadStatuses()
                        HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.7))
                    } catch {
                        ErrorService.shared.handle(error, message: "trendingStatuses.error.loadingStatusesFailed", showToastr: !Task.isCancelled)
                    }
                }
            }

        case .error(let error):
            ErrorView(error: error) {
                do {
                    self.state = .loading
                    try await self.loadStatuses()
                    self.state = .loaded
                } catch {
                    if !Task.isCancelled {
                        ErrorService.shared.handle(error, message: "trendingStatuses.error.loadingStatusesFailed", showToastr: true)
                        self.state = .error(error)
                    } else {
                        ErrorService.shared.handle(error, message: "trendingStatuses.error.loadingStatusesFailed", showToastr: false)
                    }
                }
            }
            .padding()
        }
    }

    private func loadStatuses() async throws {
        if let statuses = try await client.trends?.statuses(range: tabSelectedValue) {
            var inPlaceStatuses: [StatusModel] = []

            for item in statuses.getStatusesWithImagesOnly() {
                inPlaceStatuses.append(StatusModel(status: item))
            }

            self.statusViewModels = inPlaceStatuses
        }
    }
}
