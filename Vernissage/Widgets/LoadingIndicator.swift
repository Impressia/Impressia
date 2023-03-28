//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import SwiftUI
import ActivityIndicatorView

struct LoadingIndicator: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Binding var isVisible: Bool

    init(isVisible: Binding<Bool> = .constant(true)) {
        self._isVisible = isVisible
    }
    
    var body: some View {
        ActivityIndicatorView(isVisible: $isVisible, type: .equalizer(count: 5))
            .frame(width: 24.0, height: 16.0)
            .foregroundColor(applicationState.tintColor.color())
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator(isVisible: .constant(true))
    }
}
