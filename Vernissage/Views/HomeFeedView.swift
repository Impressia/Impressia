//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

private struct OffsetPreferenceKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

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
                // Offset reader for hiding top pill with amount of new photos.
                self.offsetReader()
                
                // VStack with all photos from database.
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
            .coordinateSpace(name: "frameLayer")
            .onPreferenceChange(OffsetPreferenceKey.self) {(offset) in
                self.calculateOpacity(offset: offset)
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
        .onChange(of: self.applicationState.amountOfNewStatuses) { newValue in
            self.calculateOffset()
        }.onAppear {
            self.calculateOffset()
        }
    }
    
    @MainActor
    private func refreshData() async {
        do {
            if let account = self.applicationState.account {
                if let lastSeenStatusId = try await HomeTimelineService.shared.loadOnTop(for: account) {
                    try await HomeTimelineService.shared.save(lastSeenStatusId: lastSeenStatusId, for: account)
                    
                    self.applicationState.lastSeenStatusId = lastSeenStatusId
                    self.applicationState.amountOfNewStatuses = 0
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "Error during download statuses from server.", showToastr: !Task.isCancelled)
        }
    }
    
    @MainActor
    private func loadData() async {
        do {
            if let account = self.applicationState.account {
                _ = try await HomeTimelineService.shared.loadOnTop(for: account)
            }
            
            self.applicationState.amountOfNewStatuses = 0
            self.state = .loaded
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "Statuses not retrieved.", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "Statuses not retrieved.", showToastr: false)
            }
        }
    }
    
    private func calculateOpacity(offset: CGFloat) {
        if self.applicationState.amountOfNewStatuses == 0 {
            return
        }
        
        // View is scrolled down.
        if offset <= 0 {
            self.opacity = 1.0
            return
        }
        
        if offset < 170 {
            // View is scrolled up (loader is visible).
            self.opacity = 1.0 - min((offset / 50.0), 1.0)
        } else {
            // View is scrolled so high that we can hide amount of new statuses.
            self.applicationState.amountOfNewStatuses = 0
            self.hideNewStatusesView()
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
    private func offsetReader() -> some View {
      GeometryReader { proxy in
        Color.clear
          .preference(
            key: OffsetPreferenceKey.self,
            value: proxy.frame(in: .named("frameLayer")).minY
          )
      }
      .frame(height: 0)
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
    private func newPhotosView() -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                Image(systemName: "arrow.up")
                Text("\(self.applicationState.amountOfNewStatuses) New \(self.applicationState.amountOfNewStatuses == 1 ? "Photo" : "Photos")")
            }
            .padding(12)
            .font(.footnote)
            .fontWeight(.light)
            .foregroundColor(Color.white)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())

            Spacer()
        }
        .padding(.top, 4)
        .padding(.trailing, 4)
    }
}
