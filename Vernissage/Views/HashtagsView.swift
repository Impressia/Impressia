//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import Foundation
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct HashtagsView: View {
    public enum ListType: Hashable {
        case trending
        case search(query: String)
    }

    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client
    @EnvironmentObject var routerPath: RouterPath

    @State public var listType: ListType

    @State private var tags: [HashtagModel] = []
    @State private var state: ViewState = .loading

    var body: some View {
        self.mainBody()
            .navigationTitle("trendingTags.navigationBar.title")
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
                NoDataView(imageSystemName: "person.3.sequence", text: "trendingTags.title.noTags")
            } else {
                self.list()
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

    @ViewBuilder
    private func list() -> some View {
        List {
            ForEach(self.tags, id: \.id) { tag in
                Section {
                    ImagesGrid(gridType: .hashtag(name: tag.hashtag))
                } header: {
                    HStack {
                        Text(tag.name).font(.headline)
                        Spacer()
                        if let total = tag.total {
                            Text(String(format: NSLocalizedString("trendingTags.title.amountOfPosts", comment: "Amount of posts"), total))
                                .font(.caption)
                        }
                    }
                    .onTapGesture {
                        self.routerPath.navigate(to: .tag(hashTag: tag.hashtag))
                    }
                }
            }
        }
    }

    private func loadData() async {
        do {
            self.tags = try await self.loadTags()
            self.state = .loaded
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "trendingTags.error.loadingTagsFailed", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "trendingTags.error.loadingTagsFailed", showToastr: false)
            }
        }
    }

    private func loadTags() async throws -> [HashtagModel] {
        switch self.listType {
        case .trending:
            let tagsFromApi = try await self.client.trends?.tags()
            return tagsFromApi?.map({ tagTrend in HashtagModel(tagTrend: tagTrend) }) ?? []
        case .search(let query):
            let results = try await self.client.search?.search(query: query, resultsType: .hashtags, limit: 40)
            return results?.hashtags.map({ tag in HashtagModel(tag: tag) }) ?? []
        }
    }
}
