//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import PixelfedKit
import Foundation

struct TrendingTagsView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath

    @State private var tags: [TagTrend] = []
    @State private var state: ViewState = .loading
    
    var body: some View {
        self.mainBody()
            .navigationTitle("Tags")
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
            if self.tags.isEmpty {
                NoDataView(imageSystemName: "person.3.sequence", text: "Unfortunately, there is no one here.")
            } else {
                List {
                    ForEach(self.tags, id: \.id) { tag in
                        Section(header: Text(tag.name).font(.headline)) {
                            TagImagesGridView(hashtag: tag.hashtag)
                                .id(UUID().uuidString)
                        }
                    }
                }
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                
                self.tags = []
                await self.loadData()
            }
            .padding()
        }
    }
    
    private func loadData() async {
        do {
            try await self.loadTags()
            self.state = .loaded
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "Tags not retrieved.", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "Tags not retrieved.", showToastr: false)
            }
        }
    }
    
    private func loadTags() async throws {
        let tagsFromApi = try await self.client.trends?.tags()
        self.tags = tagsFromApi ?? []
    }
}
