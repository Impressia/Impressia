//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import EnvironmentKit

public struct LoadingIndicator: View {
    @Environment(ApplicationState.self) var applicationState

    private let controlSize: ControlSize

    public init(controlSize: ControlSize = .regular) {
        self.controlSize = controlSize
    }

    public var body: some View {
        ProgressView()
            .tint(.gray)
            .controlSize(self.controlSize)
    }
}
