//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import HTML2Markdown

extension String {
    public var asMarkdown: String {
        do {
            let dom = try HTMLParser().parse(html: self)
            return dom.toMarkdown()
            // Add space between hashtags and mentions that follow each other
                .replacingOccurrences(of: ")[", with: ") [")
        } catch {
            return self
        }
    }
}
