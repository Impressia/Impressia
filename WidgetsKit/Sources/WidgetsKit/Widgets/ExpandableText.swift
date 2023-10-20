//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI

struct ExpandableText: View {
    let text: String
    let lineLimit: Int

    @State private var isExpanded = false
    @State private var isTruncated: Bool?

    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(calculateTruncation(text: text))

            if isTruncated == true {
                button
            }
        }
        // Re-calculate isTruncated for the new text
        .onChange(of: text) {
            isTruncated = nil
        }
    }

    func calculateTruncation(text: String) -> some View {
        // Select the view that fits in the background of the line-limited text.
        ViewThatFits(in: .vertical) {
            Text(text)
                .hidden()
                .onAppear {
                    // If the whole text fits, then isTruncated is set to false and no button is shown.
                    guard isTruncated == nil else { return }
                    isTruncated = false
                }
            Color.clear
                .hidden()
                .onAppear {
                    // If the whole text does not fit, Color.clear is selected,
                    // isTruncated is set to true and button is shown.
                    guard isTruncated == nil else { return }
                    isTruncated = true
                }
        }
    }

    var button: some View {
        HStack {
            Spacer()
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Text(isExpanded ? "global.title.showLess" : "global.title.showMore", bundle: Bundle.module, comment: "Show less/more")
                    .foregroundColor(.accentColor)
                    .textCase(.uppercase)
            }
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity)
    }
}
