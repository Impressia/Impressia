//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import HTML2Markdown

public struct Html: Codable {
    public var htmlValue: String = ""
    public var asMarkdown: String = ""
    
    init(_ htmlValue: String) {
        do {
            self.htmlValue = htmlValue
            self.asMarkdown = try self.parseToMarkdown(html: htmlValue)
        } catch {
            self.htmlValue = ""
            self.asMarkdown = ""
        }
    }
    
    public init(from decoder: Decoder) {
        do {
            let container = try decoder.singleValueContainer()
            self.htmlValue = try container.decode(String.self)
            self.asMarkdown = try self.parseToMarkdown(html: htmlValue)
        } catch {
            self.htmlValue = ""
            self.asMarkdown = ""
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(htmlValue)
    }
    
    private func parseToMarkdown(html: String) throws -> String {
        
        // Fix issue: https://github.com/VernissageApp/Home/issues/11
        let mutatedHtml = html
            .replacingOccurrences(of: "<br />\n", with: "<br />")
            .replacingOccurrences(of: "<br/>\n", with: "<br />")
            
        let dom = try HTMLParser().parse(html: mutatedHtml)
        return dom.toMarkdown()
            // Add space between hashtags and mentions that follow each other
            .replacingOccurrences(of: ")[", with: ") [")
    }
}
