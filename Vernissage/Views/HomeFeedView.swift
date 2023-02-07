//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct HomeFeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var routerPath: RouterPath
    
    @State private var amountOfNewStatuses = 0
    @State private var allItemsLoaded = false
    @State private var state: ViewState = .loading
            
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
                NoDataView(imageSystemName: "photo.on.rectangle.angled", text: "Unfortunately, there are no photos here.")
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
                                        let newStatusesCount = try await HomeTimelineService.shared.loadOnBottom(for: account)
                                        if newStatusesCount == 0 {
                                            allItemsLoaded = true
                                        }
                                    }
                                } catch {
                                    ErrorService.shared.handle(error, message: "Error during download statuses from server.", showToastr: !Task.isCancelled)
                                }
                            }
                    }
                }
            }
            
            if self.amountOfNewStatuses > 0 {
                self.newPahotosView()
            }
        }
        .task {
            await self.loadInBackground()
        }
        .refreshable {
            await self.refreshData()
        }
    }
    
    private func loadInBackground() async {
        // Refreshing in background each 1 minute.
        if let lastBackgroundRefresh = self.applicationState.lastBackgroundRefresh {
            guard let refreshDate = Calendar.current.date(byAdding: .minute, value: 1, to: lastBackgroundRefresh), refreshDate < Date.now else {
                return
            }
        }
        
        if let account = self.applicationState.account {
            self.amountOfNewStatuses = await HomeTimelineService.shared.amountOfNewStatuses(for: account)
            self.applicationState.lastBackgroundRefresh = Date.now
        }
    }
    
    private func refreshData() async {
        do {
            if let account = self.applicationState.account {
                if let lastSeenStatusId = try await HomeTimelineService.shared.loadOnTop(for: account) {
                    try await HomeTimelineService.shared.save(lastSeenStatusId: lastSeenStatusId, for: account)

                    self.applicationState.lastSeenStatusId = lastSeenStatusId
                    self.amountOfNewStatuses = 0
                    self.applicationState.lastBackgroundRefresh = Date.now
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Error during download statuses from server.", showToastr: !Task.isCancelled)
        }
    }
    
    private func loadData() async {
        do {
            if let account = self.applicationState.account {
                _ = try await HomeTimelineService.shared.loadOnTop(for: account)
            }
            
            self.amountOfNewStatuses = 0
            self.applicationState.lastBackgroundRefresh = Date.now

            self.state = .loaded
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "Error during download statuses from server.", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "Error during download statuses from server.", showToastr: false)
            }
        }
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
            Text("You're all caught up")
                .font(.title2)
                .fontWeight(.thin)
                .foregroundColor(Color.mainTextColor.opacity(0.6))
        }
        .padding(.vertical, 8)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.75)
    }
    
    @ViewBuilder
    private func newPahotosView() -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                Spacer()

                HStack {
                    Text("\(amountOfNewStatuses) new \(amountOfNewStatuses == 1 ? "photo" : "photos")")
                }
                .padding(4)
                .font(.footnote)
                .foregroundColor(Color.white.opacity(0.7))
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.top, 4)
        .padding(.trailing, 4)
    }
}
