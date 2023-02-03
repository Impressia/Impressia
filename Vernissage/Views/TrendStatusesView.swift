//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonKit

struct TrendStatusesView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client

    @State public var accountId: String

    @State private var tabSelectedValue: Mastodon.PixelfedTrends.TrendRange = .daily
    @State private var statusViewModels: [StatusModel] = []
    @State private var state: ViewState = .loading

    var body: some View {
        ScrollView {
            Picker(selection: $tabSelectedValue, label: Text("")) {
                Text("Daily").tag(Mastodon.PixelfedTrends.TrendRange.daily)
                Text("Monthly").tag(Mastodon.PixelfedTrends.TrendRange.monthly)
                Text("Yearly").tag(Mastodon.PixelfedTrends.TrendRange.yearly)
                
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
                        ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: !Task.isCancelled)
                    }
                }
            }
            
            self.mainBody()
        }
        .navigationBarTitle("Trends")
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
                            ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: true)
                            self.state = .error(error)
                        } else {
                            ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: false)
                        }
                    }
                }
        case .loaded:
            if self.statusViewModels.isEmpty {
                NoDataView(imageSystemName: "photo.on.rectangle.angled", text: "Unfortunately, there are no photos here.")
            } else {
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
                }
                .refreshable {
                    do {
                        try await self.loadStatuses()
                    } catch {
                        ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: !Task.isCancelled)
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
                        ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: true)
                        self.state = .error(error)
                    } else {
                        ErrorService.shared.handle(error, message: "Loading statuses failed.", showToastr: false)
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
