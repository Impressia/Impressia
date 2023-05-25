//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import WidgetsKit
import ClientKit

struct WaterfallGrid<Content>: View where Content: View {
    @Binding private var statusViewModels: [StatusModel]
    @Binding private var columns: Int
    @Binding private var hideLoadMore: Bool

    @State private var data: [[StatusModel]] = []

    private let onLoadMore: () async -> Void
    private let content: (StatusModel) -> Content

    init(statusViewModel: Binding<[StatusModel]>,
         columns: Binding<Int>,
         hideLoadMore: Binding<Bool>,
         content: @escaping (StatusModel) -> Content,
         onLoadMore: @escaping () async -> Void) {
        self._statusViewModels = statusViewModel
        self._columns = columns
        self._hideLoadMore = hideLoadMore
        self.content = content
        self.onLoadMore = onLoadMore
    }

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            ForEach(self.data, id: \.self) { array in
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
        .onChange(of: self.statusViewModels) { _ in
            self.recalculateArrays()
        }
        .onChange(of: self.columns) { _ in
            self.recalculateArrays()
        }
    }

    private func recalculateArrays() {
        var internalArray: [[StatusModel]] = []

        for _ in 0 ..< self.columns {
            internalArray.append([])
        }

        for (index, item) in self.statusViewModels.enumerated() {
            let arrayIndex = index % self.columns
            internalArray[arrayIndex].append(item)
        }

        self.data = internalArray
    }

    private func shouldShowSpinner(array: [StatusModel]) -> Bool {
        if self.hideLoadMore {
            return false
        }

        return self.data[1].first == array.first
    }
}
