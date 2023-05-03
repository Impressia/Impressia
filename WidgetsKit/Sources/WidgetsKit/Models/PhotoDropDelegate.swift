//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

struct PhotoDropDelegate: DropDelegate {
    let item: PhotoAttachment

    @Binding var items: [PhotoAttachment]
    @Binding var draggedItem: PhotoAttachment?

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
       return DropProposal(operation: .move)
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }

        if draggedItem != item {
            if let fromIndex = items.firstIndex(of: draggedItem),
               let toIndex = items.firstIndex(of: item) {
                withAnimation(.default) {
                    self.items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
                }
            }
        }
    }
}
