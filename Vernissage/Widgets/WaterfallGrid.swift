//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetsKit

struct WaterfallGrid<Data, ID, Content>: View where Data: RandomAccessCollection, Data: Equatable, Content: View,
                                                    ID: Hashable, Data.Element: Equatable, Data.Element: Identifiable, Data.Element: Hashable, Data.Element: Sizable {
    @Binding private var columns: Int
    @Binding private var hideLoadMore: Bool
    @Binding private var data: Data

    private let content: (Data.Element) -> Content

    @State private var columnsData: [ColumnData<Data.Element>] = []
    @State private var processedItems: [Data.Element.ID] = []
    @State private var isDuringLoading: Bool = false

    private let onLoadMore: () async -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ForEach(self.columnsData, id: \.id) { columnData in
                LazyVStack(spacing: 8) {
                    ForEach(columnData.data, id: \.id) { item in
                        self.content(item)
                    }

                    if self.hideLoadMore == false {
                        LoadingIndicator()
                            .task {
                                if isDuringLoading == false {
                                    isDuringLoading = true
                                    await self.onLoadMore()
                                    isDuringLoading = false
                                }
                            }
                    }
                }
            }
        }
        .onFirstAppear {
            self.recalculateArrays()
        }
        .onChange(of: self.data) { _ in
            self.appendToArrays()
        }
        .onChange(of: self.columns) { _ in
            self.recalculateArrays()
        }
    }

    private func recalculateArrays() {
        self.columnsData = []
        self.processedItems = []

        for _ in 0 ..< self.columns {
            self.columnsData.append(ColumnData())
        }

        for item in self.data {
            let index = self.minimumHeightIndex()

            self.columnsData[index].data.append(item)
            self.columnsData[index].height = self.columnsData[index].height + self.calculateHeight(item: item)
            self.processedItems.append(item.id)
        }
    }

    private func appendToArrays() {
        for item in self.data where self.processedItems.contains(where: { $0 == item.id }) == false {
            let index = self.minimumHeightIndex()

            self.columnsData[index].data.append(item)
            self.columnsData[index].height = self.columnsData[index].height + self.calculateHeight(item: item)
            self.processedItems.append(item.id)
        }
    }

    private func calculateHeight(item: Sizable) -> Double {
        return item.height / item.width
    }

    private func minimumHeight() -> Double {
        return self.columnsData.map({ $0.height }).min() ?? .zero
    }

    private func minimumHeightIndex() -> Int {
        let minimumHeight = self.minimumHeight()
        return self.columnsData.lastIndex(where: { $0.height == minimumHeight }) ?? 0
    }
}

extension WaterfallGrid {
    init(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, columns: Binding<Int>,
         hideLoadMore: Binding<Bool>, content: @escaping (Data.Element) -> Content, onLoadMore: @escaping () async -> Void) {
        self.content = content
        self.onLoadMore = onLoadMore

        self._data = data
        self._columns = columns
        self._hideLoadMore = hideLoadMore
    }
}

extension WaterfallGrid where ID == Data.Element.ID, Data.Element: Identifiable {
    init(_ data: Binding<Data>, columns: Binding<Int>,
         hideLoadMore: Binding<Bool>, content: @escaping (Data.Element) -> Content, onLoadMore: @escaping () async -> Void) {
        self.content = content
        self.onLoadMore = onLoadMore

        self._data = data
        self._columns = columns
        self._hideLoadMore = hideLoadMore
    }
}
