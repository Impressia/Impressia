//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI

public struct ErrorView: View {
    public var error: Error
    public var refreshAction: (() async -> Void)?

    public init(error: Error, refreshAction: (() async -> Void)? = nil) {
        self.error = error
        self.refreshAction = refreshAction
    }

    public var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .foregroundColor(.accentColor)
                .frame(width: 64, height: 64, alignment: .center)

            Text("\(error.localizedDescription)")
                .multilineTextAlignment(.center)

            if let refreshAction {
                Button {
                    Task {
                        await refreshAction()
                    }
                } label: {
                    Text("global.title.refresh", comment: "Refresh")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
