//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ActionButton<Label>: View where Label: View {
    @State public var showLoader: Bool
    @State private var isDuringAction = false
    
    private let action: () async -> Void
    private let label: () -> Label
    
    public init(showLoader: Bool = true, action: @escaping () async -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
        self.showLoader = showLoader
    }
    
    var body: some View {
        Button {
            Task {
                HapticService.shared.fireHaptic(of: .buttonPress)
                withAnimation {
                    self.isDuringAction = true
                }

                await action()
                
                withAnimation {
                    self.isDuringAction = false
                }
            }
        } label: {
            if self.showLoader {
                withLoader()
            } else {
                label()
            }
        }.disabled(isDuringAction)
    }
    
    @ViewBuilder
    private func withLoader() -> some View {
        if isDuringAction {
            LoadingIndicator(isVisible: .constant(true))
                .transition(.opacity)
        } else {
            label()
                .transition(.opacity)
        }
    }
}

