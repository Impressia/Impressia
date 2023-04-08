//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

public struct RelativeTime: View {
    @State private var text = ""

    private let date: Date
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    public init(date: Date) {
        self.date = date
    }

    public var body: some View {
        VStack {
            Text(self.text)

            // Text styles are very limited.
            // Text(date, style: .relative)
        }
        .onAppear {
            self.text = self.date.formatted(.relative(presentation: .numeric))
        }
        .onReceive(timer) { _ in
            self.text = self.date.formatted(.relative(presentation: .numeric))
        }
    }
}
