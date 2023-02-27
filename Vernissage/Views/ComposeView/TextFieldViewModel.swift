//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

@MainActor
public class TextFieldViewModel: NSObject, ObservableObject {
   
    var textView: UITextView?

    var selectedRange: NSRange {
      get {
        guard let textView else {
          return .init(location: 0, length: 0)
        }
          
        return textView.selectedRange
      }
      set {
        textView?.selectedRange = newValue
      }
    }

    var markedTextRange: UITextRange? {
      guard let textView else {
        return nil
      }
      return textView.markedTextRange
    }
    
    @Published var text = NSMutableAttributedString(string: "") {
      didSet {
        let range = selectedRange
        processText()
        // checkEmbed()
        textView?.attributedText = text
        selectedRange = range
      }
    }
    
    private var urlLengthAdjustments: Int = 0
    private let maxLengthOfUrl = 23

    public func append(content: String) {
        let attrString = self.text
        attrString.append(NSAttributedString(string: content))
        self.text = attrString
        
        selectedRange.location += content.utf16.count
    }
    
    private func processText() {
        guard markedTextRange == nil else { return }

        text.addAttributes([.foregroundColor: UIColor(Color.label),
                            .font: UIFont.systemFont(ofSize: TextView.bodyFontSize),
                            .backgroundColor: UIColor.clear,
                            .underlineColor: UIColor.clear],
                           range: NSMakeRange(0, text.string.utf16.count))

        let hashtagPattern = "(#+[a-zA-Z0-9(_)]{1,})"
        let mentionPattern = "(@+[a-zA-Z0-9(_).-]{1,})"
        let urlPattern = "(?i)https?://(?:www\\.)?\\S+(?:/|\\b)"

        do {
            let hashtagRegex = try NSRegularExpression(pattern: hashtagPattern, options: [])
            let mentionRegex = try NSRegularExpression(pattern: mentionPattern, options: [])
            let urlRegex = try NSRegularExpression(pattern: urlPattern, options: [])

            let range = NSMakeRange(0, text.string.utf16.count)
            var ranges = hashtagRegex.matches(in: text.string, options: [], range: range).map { $0.range }
            ranges.append(contentsOf: mentionRegex.matches(in: text.string, options: [], range: range).map { $0.range })

            let urlRanges = urlRegex.matches(in: text.string, options: [], range: range).map { $0.range }

            // var foundSuggestionRange = false
            for nsRange in ranges {
                text.addAttributes([.foregroundColor: UIColor(.accentColor)], range: nsRange)
                
//                if selectedRange.location == (nsRange.location + nsRange.length),
//                   let range = Range(nsRange, in: text.string) {
//                    foundSuggestionRange = true
//                    currentSuggestionRange = nsRange
//                    loadAutoCompleteResults(query: String(text.string[range]))
//                }
            }

//            if !foundSuggestionRange || ranges.isEmpty {
//                resetAutoCompletion()
//            }

            var totalUrlLength = 0
            var numUrls = 0

            for range in urlRanges {
                if range.length > maxLengthOfUrl {
                    numUrls += 1
                    totalUrlLength += range.length
                }

                text.addAttributes([.foregroundColor: UIColor(.accentColor),
                                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                                    .underlineColor: UIColor(.accentColor)],
                                   range: NSRange(location: range.location, length: range.length))
            }

            urlLengthAdjustments = totalUrlLength - (maxLengthOfUrl * numUrls)

            text.enumerateAttributes(in: range) { attributes, range, _ in
                if attributes[.link] != nil {
                    text.removeAttribute(.link, range: range)
                }
            }
        } catch { }

    }
}

