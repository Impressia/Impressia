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
    
    @State private var allItemsBottomLoaded = false
    @State private var state: ViewState = .loading
    
    private static let initialColumns = 1
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
        
    @FetchRequest var dbStatuses: FetchedResults<StatusData>
    
    init(accountId: String) {
        _dbStatuses = FetchRequest<StatusData>(
            sortDescriptors: [SortDescriptor(\.id, order: .reverse)],
            predicate: NSPredicate(format: "pixelfedAccount.id = %@", accountId))
    }
    
    var body: some View {
        self.mainBody()
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
            if self.dbStatuses.isEmpty {
                NoDataView(imageSystemName: "photo.on.rectangle.angled", text: "Unfortunately, there are no photos here.")
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns) {
                        ForEach(dbStatuses, id: \.self) { item in
                            
                            if self.shouldUpToDateBeVisible(statusId: item.id) {
                                self.upToDatePlaceholder()
                            }
                            
                            NavigationLink(value: RouteurDestinations.status(
                                id: item.rebloggedStatusId ?? item.id,
                                blurhash: item.attachments().first?.blurhash,
                                highestImageUrl: item.attachments().getHighestImage()?.url,
                                metaImageWidth: item.attachments().first?.metaImageWidth,
                                metaImageHeight: item.attachments().first?.metaImageHeight)
                            ) {
                                ImageRow(statusData: item)
                            }
                            .buttonStyle(EmptyButtonStyle())
                        }
                        
                        if allItemsBottomLoaded == false {
                            LoadingIndicator()
                                .task {
                                    do {
                                        if let account = self.applicationState.account {
                                            let newStatusesCount = try await HomeTimelineService.shared.loadOnBottom(for: account)
                                            if newStatusesCount == 0 {
                                                allItemsBottomLoaded = true
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
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadData()
            }
            .padding()
        }
    }
    
    private func loadData() async {
        do {
            if self.dbStatuses.isEmpty == false {
                self.state = .loaded
                return
            }

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
