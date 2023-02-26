//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct PhotoEditorView: View {
    @EnvironmentObject var client: Client
    @Environment(\.dismiss) private var dismiss
    
    @State private var description: String = String.empty()
    @ObservedObject public var photoAttachment: PhotoAttachment
        
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                if let data = photoAttachment.photoData, let uiImage = UIImage(data: data) {
                    List {
                        Section(header: Text("Photo")) {
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
                        
                        Section(header: Text("Accessibility")) {
                            TextField("Sescription for the visually impaired", text: $description, axis: .vertical)
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
            .navigationTitle("Photo details")
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
                Text("Save")
            }.buttonStyle(.borderedProminent)
        }
        
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel", role: .cancel) {
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
                ErrorService.shared.handle(error, message: "Cannot update attachment.", showToastr: true)
            }
        }
    }
}

