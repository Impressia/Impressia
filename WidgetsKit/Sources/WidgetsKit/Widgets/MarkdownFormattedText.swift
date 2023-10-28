//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import UIKit
import SwiftUI
import EmojiText
import EnvironmentKit

public struct MarkdownFormattedText: View {
    @Environment(ApplicationState.self) var applicationState

    private let markdown: String
    private let textView = UITextView()

    public init(_ markdown: String) {
        self.markdown = markdown
    }

    public var body: some View {
        EmojiText(markdown: markdown, emojis: [])
    }
}
