//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct PhotoEditorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var description: String = String.empty()
    @ObservedObject public var photoAttachment: PhotoAttachment
        
    var body: some View {
        VStack(alignment: .leading) {
            if let uiImage = UIImage(data: photoAttachment.photoData) {
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
                            .lineLimit(2...5)
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
            self.description = self.photoAttachment.description
        }
        .navigationBarTitle("Photo details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            self.getTrailingToolbar()
        }
    }
    
    @ToolbarContentBuilder
    private func getTrailingToolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                HapticService.shared.touch()
                self.photoAttachment.description = self.description
                self.hideKeyboard()

                self.dismiss()
            } label: {
                Text("Update")
            }.buttonStyle(.borderedProminent)
        }
    }
}

