//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import ClientKit
import ServicesKit

public struct PhotoEditorView: View {
    @EnvironmentObject var client: Client
    @Environment(\.dismiss) private var dismiss

    @State private var description: String = String.empty()
    @ObservedObject public var photoAttachment: PhotoAttachment

    public init(photoAttachment: PhotoAttachment) {
        self.photoAttachment = photoAttachment
    }

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if let data = photoAttachment.photoData, let uiImage = UIImage(data: data) {
                    List {
                        Section(header: Text("photoEdit.title.photo")) {
                            HStack {
                                Spacer()
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .frame(maxHeight: 300)
                                Spacer()
                            }
                        }

                        Section(header: Text("photoEdit.title.accessibility")) {
                            TextField(NSLocalizedString("photoEdit.title.accessibilityDescription", bundle: Bundle.module, comment: "Accesibility"), text: $description, axis: .vertical)
                                .keyboardType(.default)
                                .lineLimit(3...6)
                                .multilineTextAlignment(.leading)
                        }
                    }.listStyle(.grouped)

                    Spacer()
                }
            }
            .onDisappear {
                self.hideKeyboard()
            }
            .onAppear {
                self.description = self.photoAttachment.uploadedAttachment?.description ?? String.empty()
            }
            .navigationTitle(NSLocalizedString("photoEdit.navigationBar.title", bundle: Bundle.module, comment: "Title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                self.getTrailingToolbar()
            }
        }
    }

    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            ActionButton(showLoader: false) {
                await self.update()
            } label: {
                Text("photoEdit.title.save", bundle: Bundle.module, comment: "Save")
            }.buttonStyle(.borderedProminent)
        }

        ToolbarItem(placement: .cancellationAction) {
            Button(NSLocalizedString("photoEdit.title.cancel", bundle: Bundle.module, comment: "Cancel"), role: .cancel) {
                dismiss()
            }
        }
    }

    private func update() async {
        HapticService.shared.fireHaptic(of: .buttonPress)
        self.hideKeyboard()

        if let uploadedAttachment = self.photoAttachment.uploadedAttachment {
            do {
                let updated = try await self.client.media?.update(id: uploadedAttachment.id,
                                                                  description: self.description,
                                                                  focus: nil)

                self.photoAttachment.uploadedAttachment = updated
                self.dismiss()
            } catch {
                ErrorService.shared.handle(error, message: "photoEdit.error.updatePhotoFailed", showToastr: true)
            }
        }
    }
}
