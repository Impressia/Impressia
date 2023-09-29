//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct HomeFeedView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var routerPath: RouterPath

    @State private var allItemsLoaded = false
    @State private var state: ViewState = .loading

    @State private var opacity = 0.0
    @State private var offset = -50.0

    @FetchRequest var dbStatuses: FetchedResults<StatusData>

    init(accountId: String) {
        _dbStatuses = FetchRequest<StatusData>(
            sortDescriptors: [SortDescriptor(\.id, order: .reverse)],
            predicate: NSPredicate(format: "pixelfedAccount.id = %@", accountId))
    }

    var body: some View {
        switch state {
        case .loading:
            LoadingIndicator()
                .task {
                    await self.loadData()
                }
        case .loaded:
            if self.dbStatuses.isEmpty {
                NoDataView(imageSystemName: "photo.on.rectangle.angled", text: "home.title.noPhotos")
            } else {
                self.timeline()
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
    private func timeline() -> some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    ForEach(dbStatuses, id: \.self) { item in
                        if self.shouldUpToDateBeVisible(statusId: item.id) {
                            self.upToDatePlaceholder()
                        }

                        ImageRow(statusData: item)
                    }

                    if allItemsLoaded == false {
                        LoadingIndicator()
                            .task {
                                do {
                                    if let account = self.applicationState.account {
                                        let newStatusesCount = try await HomeTimelineService.shared.loadOnBottom(for: account, includeReblogs: self.applicationState.showReboostedStatuses)
                                        if newStatusesCount == 0 {
                                            allItemsLoaded = true
                                        }
                                    }
                                } catch {
                                    ErrorService.shared.handle(error, message: "global.error.errorDuringDownloadStatuses", showToastr: !Task.isCancelled)
                                }
                            }
                    }
                }
            }

            self.newPhotosView()
                .offset(y: self.offset)
                .opacity(self.opacity)
        }
        .refreshable {
            HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.3))
            await self.refreshData()
            HapticService.shared.fireHaptic(of: .dataRefresh(intensity: 0.7))
        }
        .onChange(of: self.applicationState.amountOfNewStatuses) { _ in
            self.calculateOffset()
        }.onAppear {
            self.calculateOffset()
        }
    }

    private func refreshData() async {
        do {
            if let account = self.applicationState.account {
                let lastSeenStatusId = try await HomeTimelineService.shared.refreshTimeline(for: account, includeReblogs: self.applicationState.showReboostedStatuses, updateLastSeenStatus: true)

                asyncAfter(0.35) {
                    self.applicationState.lastSeenStatusId = lastSeenStatusId
                    self.applicationState.amountOfNewStatuses = 0
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "global.error.errorDuringDownloadStatuses", showToastr: !Task.isCancelled)
        }
    }

    private func loadData() async {
        do {
            // We have to load data automatically only when the database is empty.
            guard self.dbStatuses.isEmpty else {
                withAnimation {
                    self.state = .loaded
                }

                return
            }

            if let account = self.applicationState.account {
                _ = try await HomeTimelineService.shared.refreshTimeline(for: account, includeReblogs: self.applicationState.showReboostedStatuses)
            }

            self.applicationState.amountOfNewStatuses = 0
            self.state = .loaded
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "global.error.statusesNotRetrieved", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "global.error.statusesNotRetrieved", showToastr: false)
            }
        }
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

    private func shouldUpToDateBeVisible(statusId: String) -> Bool {
        return self.applicationState.lastSeenStatusId != dbStatuses.first?.id && self.applicationState.lastSeenStatusId == statusId
    }

    @ViewBuilder
    private func upToDatePlaceholder() -> some View {
        VStack(alignment: .center) {
            Image(systemName: "checkmark.seal")
                .resizable()
                .frame(width: 64, height: 64)
                .fontWeight(.ultraLight)
                .foregroundColor(.accentColor.opacity(0.6))
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
}
