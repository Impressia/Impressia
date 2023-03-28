//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import UIKit
import SwiftUI
import EmojiText
import HTML2Markdown

struct MarkdownFormattedText: View {
    @EnvironmentObject var applicationState: ApplicationState

    private let markdown: String
    private let textView = UITextView()

    init(_ markdown: String) {
        self.markdown = markdown
    }

    var body: some View {
        EmojiText(markdown: markdown, emojis: [])
    }
}
