//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct HomeFeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var applicationState: ApplicationState
    
    @State private var showLoading = false
    
    private static let initialColumns = 1
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id, order: .reverse)]) var dbStatuses: FetchedResults<StatusData>
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: gridColumns) {
                    ForEach(dbStatuses, id: \.self) { item in
                        NavigationLink(destination: StatusView(statusId: item.id,
                                                               imageBlurhash: item.attachments().first?.blurhash,
                                                               imageWidth: item.attachments().first?.metaImageWidth,
                                                               imageHeight: item.attachments().first?.metaImageHeight)
                            .environmentObject(applicationState)) {
                            ImageRow(status: item)
                        }
                        .buttonStyle(EmptyButtonStyle())
                    }
                    
                    LoadingIndicator()
                        .onAppear {
                            Task {
                                do {
                                    if let accountData = self.applicationState.accountData {
                                        try await TimelineService.shared.onBottomOfList(for: accountData)
                                    }
                                } catch {
                                    print("Error", error)
                                }
                            }
                        }
                }
            }
            
            if showLoading {
                LoadingIndicator()
            }
        }
        .refreshable {
            do {
                if let accountData = self.applicationState.accountData {
                    try await TimelineService.shared.onTopOfList(for: accountData)
                }
            } catch {
                print("Error", error)
            }
        }
        .task {
            do {
                if self.dbStatuses.isEmpty {
                    self.showLoading = true
                    if let accountData = self.applicationState.accountData {
                        try await TimelineService.shared.onTopOfList(for: accountData)
                    }
                    self.showLoading = false
                }
            } catch {
                self.showLoading = false
                print("Error", error)
            }
        }
    }
}

struct HomeFeedView_Previews: PreviewProvider {
    static var previews: some View {
        HomeFeedView()
    }
}
