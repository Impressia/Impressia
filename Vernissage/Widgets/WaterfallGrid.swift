//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetsKit

struct WaterfallGrid<Data, ID, Content>: View where Data: RandomAccessCollection, Data: Equatable, Content: View,
                                                    ID: Hashable, Data.Element: Equatable, Data.Element: Identifiable, Data.Element: Hashable {
    @Binding private var columns: Int
    @Binding private var hideLoadMore: Bool

    @Binding private var data: Data
    private let dataId: KeyPath<Data.Element, ID>
    private let content: (Data.Element) -> Content

    @State private var columnsData: [[Data.Element]] = []

    private let onLoadMore: () async -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ForEach(self.columnsData, id: \.self) { array in
                LazyVStack(spacing: 8) {
                    ForEach(array, id: \.id) { item in
                        self.content(item)
                    }

                    if self.shouldShowSpinner(array: array) {
                        LoadingIndicator()
                            .task {
                                await self.onLoadMore()
                            }
                    }
                }
            }
        }
        .onFirstAppear {
            self.recalculateArrays()
        }
        .onChange(of: self.data) { _ in
            self.recalculateArrays()
        }
        .onChange(of: self.columns) { _ in
            self.recalculateArrays()
        }
    }

    private func recalculateArrays() {
        var internalArray: [[Data.Element]] = []

        for _ in 0 ..< self.columns {
            internalArray.append([])
        }

        for (index, item) in self.data.enumerated() {
            let arrayIndex = index % self.columns
            internalArray[arrayIndex].append(item)
        }

        self.columnsData = internalArray
    }

    private func shouldShowSpinner(array: [Data.Element]) -> Bool {
        if self.hideLoadMore {
            return false
        }

        return self.columnsData[1].first == array.first
    }

}

extension WaterfallGrid {
    init(_ data: Binding<Data>, id: KeyPath<Data.Element, ID>, columns: Binding<Int>,
         hideLoadMore: Binding<Bool>, content: @escaping (Data.Element) -> Content, onLoadMore: @escaping () async -> Void) {
        self._data = data
        self.dataId = id
        self.content = content

        self._columns = columns
        self._hideLoadMore = hideLoadMore
        self.onLoadMore = onLoadMore
    }
}

extension WaterfallGrid where ID == Data.Element.ID, Data.Element: Identifiable {
    init(_ data: Binding<Data>, columns: Binding<Int>,
         hideLoadMore: Binding<Bool>, content: @escaping (Data.Element) -> Content, onLoadMore: @escaping () async -> Void) {
        self._data = data
        self.dataId = \Data.Element.id
        self.content = content

        self._columns = columns
        self._hideLoadMore = hideLoadMore
        self.onLoadMore = onLoadMore
    }
}
