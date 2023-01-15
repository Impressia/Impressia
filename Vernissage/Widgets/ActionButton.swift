//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct ActionButton<Label> : View where Label : View {
    @State private var isDuringAction = false
    
    private let action: () async -> Void
    private let label: () -> Label
    
    public init(action: @escaping () async -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }
    
    var body: some View {
        Button {
            Task {
                HapticService.shared.touch()
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

                await action()
            }
        } label: {
            if isDuringAction {
                LoadingIndicator(isVisible: .constant(true))
                    .transition(.opacity)
            } else {
                label()
                    .transition(.opacity)
            }
        }.disabled(isDuringAction)
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton {
            
        } label: {
            Text("Action")
        }

    }
}
