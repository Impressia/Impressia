//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import PhotosUI
import SwiftUI
import PixelfedKit

struct EditProfileView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    @Environment(\.dismiss) private var dismiss
    
    @State private var photosPickerVisible = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var saveDisabled = false
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var avatarData: Data?
    
    private let account: Account
    
    init(account: Account) {
        self.account = account
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack {
                        ZStack {
                            if let avatarData, let uiAvatar = UIImage(data: avatarData) {
                                Image(uiImage: uiAvatar)
                                    .resizable()
                                    .clipShape(applicationState.avatarShape.shape())
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 96, height: 96)
                            } else {
                                UserAvatar(accountAvatar: account.avatar, size: .profile)
                            }

                            BottomRight {
                                Button {
                                    self.photosPickerVisible = true
                                } label: {
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .font(.title)
                                        .foregroundColor(.accentColor)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .frame(width: 96, height: 96)
                        }
                        
                        Text("@\(self.account.acct)")
                            .font(.subheadline)
                            .foregroundColor(.lightGrayColor)
                    }
                    
                    Spacer()
                }
            }
            .padding(0)
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            .listRowSeparator(Visibility.hidden)
            
            Section("editProfile.title.displayName") {
                TextField("", text: $displayName)
            }
            
            Section("editProfile.title.bio") {
                TextField("", text: $bio, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ActionButton(showLoader: false) {
                    await self.saveProfile()
                } label: {
                    Text("editProfile.title.save", comment: "Save")
                }
                .disabled(self.saveDisabled)
                .buttonStyle(.borderedProminent)
            }
        }
        .navigationTitle("editProfile.navigationBar.title")
        .onAppear {
            self.displayName = self.account.displayName ?? String.empty()
            
            let markdownBio = self.account.note?.asMarkdown ?? String.empty()
            if let attributedString = try? AttributedString(markdown: markdownBio) {
                self.bio = String(attributedString.characters)
            }
        }
        .onChange(of: self.selectedItems) { selectedItem in
            Task {
                await self.getAvatar()
            }
        }
        .photosPicker(isPresented: $photosPickerVisible,
                      selection: $selectedItems,
                      maxSelectionCount: 1,
                      matching: .images)
    }
    
    private func saveProfile() async {
        do {
            _ = try await self.client.accounts?.update(displayName: self.displayName, bio: self.bio, image: self.avatarData)
            ToastrService.shared.showSuccess("editProfile.title.accountSaved", imageSystemName: "person.crop.circle")
            dismiss()
        } catch {
            ErrorService.shared.handle(error, message: "editProfile.error.saveAccountFailed", showToastr: true)
        }
    }
    
    private func getAvatar() async {
        do {
            self.saveDisabled = true
            
            for item in self.selectedItems {
                if let data = try await item.loadTransferable(type: Data.self) {
                    self.avatarData = data
                }
            }
            
            guard let imageData = self.avatarData else {
                return
            }

            guard let image = UIImage(data: imageData) else {
                return
            }
            
            guard let data = image
                .resized(to: .init(width: 400, height: 400))
                .getJpegData() else {
                return
            }

            self.avatarData = data
            
            self.saveDisabled = false
        } catch {
            ErrorService.shared.handle(error, message: "editProfile.error.loadingAvatarFailed", showToastr: true)
        }
    }
}
