//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

struct HTMLFormattedText: UIViewRepresentable {

    let text: String
    private let textView = UITextView()
    private let fontSize: Int
    private let width: Int

    init(_ content: String, withFontSize fontSize: Int = 16, andWidth width: Int? = nil) {
        self.text = content
        self.fontSize = fontSize
        self.width = width ?? Int(UIScreen.main.bounds.width) - 16
    }

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        textView.widthAnchor.constraint(equalToConstant: CGFloat(self.width)).isActive = true
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor(Color.clear)

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        DispatchQueue.main.async {
            if let attributeText = self.converHTML(text: text) {
                textView.attributedText = attributeText
            } else {
                textView.text = ""
            }
        }
    }

    private func converHTML(text: String) -> NSAttributedString?{
        guard let data = text.data(using: .utf16) else {
            return nil
        }
      
        let largeAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(self.fontSize)),
            NSAttributedString.Key.foregroundColor: UIColor(Color("MainTextColor"))
        ]

        let linkAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(self.fontSize)),
            NSAttributedString.Key.foregroundColor: UIColor(Color.accentColor)
        ]
      
        if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
          
            attributedString.enumerateAttributes(in: NSRange(0..<attributedString.length)) { value, range, stop in
              attributedString.setAttributes(largeAttributes, range: range)

                if value.keys.contains(NSAttributedString.Key.link) {
                    attributedString.setAttributes(linkAttributes, range: range)
                }
            }
                    
            return attributedString
        } else{
            return nil
        }
    }
}

struct HTMLFotmattedText_Previews: PreviewProvider {
    static var previews: some View {
        HTMLFormattedText("<p>Danish-made 1st class kebab</p><p>Say yes thanks to 2kg. delicious kebab, which is confused and cooked.</p><p>Yes thanks for 149.95</p><p>Now you can make the most delicious sandwiches, kebab mix and much more at home</p>")
    }
}
