//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ServicesKit

public struct ActionMenu<Label: View, Content: View>: View {
    @State private var isDuringAction = false

    private let primaryAction: () async -> Void
    private let label: () -> Label
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content, @ViewBuilder label: @escaping () -> Label, primaryAction: @escaping () async -> Void) {
        self.label = label
        self.content = content
        self.primaryAction = primaryAction
    }

    public var body: some View {
        Menu {
            content()
        } label: {
            if isDuringAction {
                LoadingIndicator(isVisible: .constant(true))
                    .transition(.opacity)
            } else {
                label()
                    .transition(.opacity)
            }
        } primaryAction: {
            Task {
                HapticService.shared.fireHaptic(of: .buttonPress)
                defer {
                    Task { @MainActor in
                        withAnimation {
                            self.isDuringAction = false
                        }
                    }
                }

                withAnimation {
                    self.isDuringAction = true
                }

                await primaryAction()
            }
        }.disabled(isDuringAction)
    }
}
