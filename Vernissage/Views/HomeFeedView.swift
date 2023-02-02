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
        .refreshable {
            do {
                if let account = self.applicationState.account {
                    if let lastSeenStatusId = try await HomeTimelineService.shared.loadOnTop(for: account) {
                        try await HomeTimelineService.shared.save(lastSeenStatusId: lastSeenStatusId, for: account)
                        self.applicationState.lastSeenStatusId = lastSeenStatusId
                    }
                }
            } catch {
                ErrorService.shared.handle(error, message: "Error during download statuses from server.", showToastr: !Task.isCancelled)
            }
        }
    }
    
    private func loadData() async {
        do {
            if let account = self.applicationState.account {
                _ = try await HomeTimelineService.shared.loadOnTop(for: account)
            }
            
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
}
