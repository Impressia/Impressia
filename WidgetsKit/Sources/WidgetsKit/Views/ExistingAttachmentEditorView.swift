//
//  https://mczachurski.dev
//  Copyright © 2025 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ClientKit

/// View for editing the alt text of an existing media attachment (edit mode).
/// The new description is stored locally and saved when the user confirms the post edit.
@MainActor
public struct ExistingAttachmentEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var description: String

    public var attachment: AttachmentModel
    public let onSave: (String) -> Void

    public init(attachment: AttachmentModel, onSave: @escaping (String) -> Void) {
        self.attachment = attachment
        self.onSave = onSave
        self._description = State(initialValue: attachment.description ?? "")
    }

    public var body: some View {
        NavigationView {
            List {
                Section(header: Text("photoEdit.title.photo", bundle: Bundle.module, comment: "Photo")) {
                    HStack {
                        Spacer()
                        self.photoView()
                        Spacer()
                    }
                }

                Section(header: Text("photoEdit.title.accessibility", bundle: Bundle.module, comment: "Accessibility")) {
                    TextField(
                        NSLocalizedString("photoEdit.title.accessibilityDescription", bundle: Bundle.module, comment: "Description for the visually impaired"),
                        text: $description,
                        axis: .vertical
                    )
                    .keyboardType(.default)
                    .lineLimit(3...6)
                    .multilineTextAlignment(.leading)
                }
            }
            .listStyle(.grouped)
            .onDisappear {
                self.hideKeyboard()
            }
            .navigationTitle(NSLocalizedString("photoEdit.navigationBar.title", bundle: Bundle.module, comment: "Photo details"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                self.getTrailingToolbar()
            }
        }
    }

    @ViewBuilder
    private func photoView() -> some View {
        let url = attachment.previewUrl ?? attachment.url
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .frame(maxHeight: 300)
            default:
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 200)
            }
        }
    }

    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                self.save()
            } label: {
                Text("compose.title.edit", bundle: Bundle.module, comment: "Edit")
            }
            .buttonStyle(.borderedProminent)
        }

        ToolbarItem(placement: .cancellationAction) {
            Button(NSLocalizedString("photoEdit.title.cancel", bundle: Bundle.module, comment: "Cancel"), role: .cancel) {
                dismiss()
            }
        }
    }

    private func save() {
        self.hideKeyboard()
        // Alt text is saved when the user confirms the post edit via the main "Edit" button.
        // We just store the new value locally here.
        self.onSave(self.description)
        self.dismiss()
    }
}
