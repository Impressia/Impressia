//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import UIKit
import SwiftUI
import EmojiText
import HTML2Markdown

struct MarkdownFormattedText: View {
    @EnvironmentObject var applicationState: ApplicationState

    private let markdown: String
    private let textView = UITextView()
    private let fontSize: CGFloat
    private let width: Int

    init(_ markdown: String, withFontSize fontSize: CGFloat = 16, andWidth width: Int? = nil) {
        self.markdown = markdown
        self.fontSize = fontSize
        self.width = width ?? Int(UIScreen.main.bounds.width) - 16
    }

    var body: some View {
        EmojiText(markdown: markdown, emojis: [])
            .font(.system(size: self.fontSize))
    }
}
