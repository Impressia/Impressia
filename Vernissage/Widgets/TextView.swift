//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import SwiftUI

public struct TextView: View {
    @Environment(\.layoutDirection) private var layoutDirection

    @Binding private var text: NSMutableAttributedString
    @Binding private var isEmpty: Bool

    @State private var calculatedHeight: CGFloat = 44

    private var getTextView: ((UITextView) -> Void)?
    public static let bodyFontSize = 17.0
    
    var placeholderView: AnyView?
    var keyboard: UIKeyboardType = .default

    public init(_ text: Binding<NSMutableAttributedString>,
                getTextView: ((UITextView) -> Void)? = nil)
    {
        _text = text
        _isEmpty = Binding(
            get: { text.wrappedValue.string.isEmpty },
            set: { _ in }
        )

        self.getTextView = getTextView
    }

    public var body: some View {
        Representable(
            text: $text,
            calculatedHeight: $calculatedHeight,
            keyboard: keyboard,
            getTextView: getTextView
        )
        .frame(
            minHeight: calculatedHeight,
            maxHeight: calculatedHeight
        )
        .background(
            placeholderView?
                .foregroundColor(Color(.placeholderText))
                .multilineTextAlignment(.leading)
                .font(Font.body)
                .padding(.horizontal, 0)
                .padding(.vertical, 0)
                .opacity(isEmpty ? 1 : 0),
            alignment: .topLeading
        )
    }
}

final class UIKitTextView: UITextView {
    override var keyCommands: [UIKeyCommand]? {
        return (super.keyCommands ?? []) + [
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(escape(_:))),
        ]
    }

    @objc private func escape(_: Any) {
        resignFirstResponder()
    }
}

extension TextView {
    struct Representable: UIViewRepresentable {
        
        @Binding var text: NSMutableAttributedString
        @Binding var calculatedHeight: CGFloat

        let keyboard: UIKeyboardType
        var getTextView: ((UITextView) -> Void)?

        func makeUIView(context: Context) -> UIKitTextView {
            context.coordinator.textView
        }

        func updateUIView(_: UIKitTextView, context: Context) {
            context.coordinator.update(representable: self)
            if !context.coordinator.didBecomeFirstResponder {
                context.coordinator.textView.becomeFirstResponder()
                context.coordinator.didBecomeFirstResponder = true
            }
        }

        @discardableResult func makeCoordinator() -> Coordinator {
            Coordinator(
                text: $text,
                calculatedHeight: $calculatedHeight,
                getTextView: getTextView
            )
        }
    }
}

extension TextView.Representable {
    final class Coordinator: NSObject, UITextViewDelegate {
        internal let textView: UIKitTextView

        private var originalText: NSMutableAttributedString = .init()
        private var text: Binding<NSMutableAttributedString>
        private var calculatedHeight: Binding<CGFloat>

        var didBecomeFirstResponder = false
        
        var getTextView: ((UITextView) -> Void)?

        init(text: Binding<NSMutableAttributedString>,
             calculatedHeight: Binding<CGFloat>,
             getTextView: ((UITextView) -> Void)?) {

            textView = UIKitTextView()
            textView.backgroundColor = .clear
            textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            textView.isScrollEnabled = false
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainerInset = .zero

            self.text = text
            self.calculatedHeight = calculatedHeight
            self.getTextView = getTextView

            super.init()

            textView.delegate = self

            textView.font = .systemFont(ofSize: TextView.bodyFontSize)
            textView.adjustsFontForContentSizeCategory = true
            textView.autocapitalizationType = .sentences
            textView.autocorrectionType = .yes
            textView.isEditable = true
            textView.isSelectable = true
            textView.dataDetectorTypes = []
            textView.allowsEditingTextAttributes = false
            textView.returnKeyType = .default
            textView.allowsEditingTextAttributes = true

            self.getTextView?(textView)
        }

        func textViewDidBeginEditing(_: UITextView) {
            originalText = text.wrappedValue
            DispatchQueue.main.async {
                self.recalculateHeight()
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.text.wrappedValue = NSMutableAttributedString(attributedString: textView.attributedText)
                self.recalculateHeight()
            }
        }

        func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText _: String) -> Bool {
            return true
        }
    }
}

extension TextView.Representable.Coordinator {
    func update(representable: TextView.Representable) {
        textView.keyboardType = representable.keyboard
        recalculateHeight()
        textView.setNeedsDisplay()
    }

    private func recalculateHeight() {
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude))
        guard calculatedHeight.wrappedValue != newSize.height else { return }

        DispatchQueue.main.async { // call in next render cycle.
            self.calculatedHeight.wrappedValue = newSize.height
        }
    }
}

public extension TextView {
    /// Specify a placeholder text
    /// - Parameter placeholder: The placeholder text
    func placeholder(_ placeholder: String) -> TextView {
        self.placeholder(placeholder) { $0 }
    }

    /// Specify a placeholder with the specified configuration
    ///
    /// Example:
    ///
    ///     TextView($text)
    ///         .placeholder("placeholder") { view in
    ///             view.foregroundColor(.red)
    ///         }
    func placeholder<V: View>(_ placeholder: String, _ configure: (Text) -> V) -> TextView {
        var view = self
        let text = Text(placeholder)
        view.placeholderView = AnyView(configure(text))
        return view
    }

    /// Specify a custom placeholder view
    func placeholder<V: View>(_ placeholder: V) -> TextView {
        var view = self
        view.placeholderView = AnyView(placeholder)
        return view
    }

    func setKeyboardType(_ keyboardType: UIKeyboardType) -> TextView {
        var view = self
        view.keyboard = keyboardType
        return view
    }
}

