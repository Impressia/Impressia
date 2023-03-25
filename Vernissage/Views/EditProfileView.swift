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
    @State private var website: String = ""
    @State private var isPrivate = false
    @State private var avatarData: Data?
    
    private let account: Account
    private let bioMaxLength = 200
    private let displayNameMaxLength = 30
    private let websiteMaxLength = 120
    
    init(account: Account) {
        self.account = account
    }

    var body: some View {
        Form {
            HStack {
                Spacer()
                VStack {
                    ZStack {
                        if let avatarData, let uiAvatar = UIImage(data: avatarData) {
                            Image(uiImage: uiAvatar)
                                .resizable()
                                .clipShape(applicationState.avatarShape.shape())
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                        } else {
                            UserAvatar(accountAvatar: account.avatar, size: .large)
                        }
                        
                        LoadingIndicator(isVisible: $saveDisabled)

                        BottomRight {
                            Button {
                                self.photosPickerVisible = true
                            } label: {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.accentColor.opacity(0.8))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "person.crop.circle.badge.plus")
                                        .font(.title2)
                                        .foregroundColor(.white)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .frame(width: 130, height: 130)
                    }
                    
                    Text("@\(self.account.acct)")
                        .font(.headline)
                        .foregroundColor(.lightGrayColor)
                    
                    if self.avatarData != nil {
                        HStack {
                            Image(systemName: "info.circle")
                                .font(.body)
                                .foregroundColor(.accentColor)
                            Text("editProfile.title.photoInfo")
                                .font(.footnote)
                                .foregroundColor(.lightGrayColor)
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
            .padding(-10)
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            .listRowSeparator(Visibility.hidden)

            Section {
                TextField("", text: $displayName)
                    .onChange(of: self.displayName, perform: { newValue in
                        self.displayName = String(self.displayName.prefix(self.displayNameMaxLength))
                    })
            } header: {
                Text("editProfile.title.displayName", comment: "Display name")
            } footer: {
                HStack {
                    Spacer()
                    Text("\(self.displayName.count)/\(self.displayNameMaxLength)")
                }
            }
            
            Section {
                TextField("", text: $bio, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
                    .onChange(of: self.bio, perform: { newValue in
                        self.bio = String(self.bio.prefix(self.bioMaxLength))
                    })
            } header: {
                Text("editProfile.title.bio", comment: "Bio")
            } footer: {
                HStack {
                    Spacer()
                    Text("\(self.bio.count)/\(self.bioMaxLength)")
                }
            }
            
            Section {
                TextField("", text: $website)
                    .autocapitalization(.none)
                    .keyboardType(.URL)
                    .autocorrectionDisabled()
                    .onChange(of: self.website, perform: { newValue in
                        self.website = String(self.website.prefix(self.websiteMaxLength))
                    })
            } header: {
                Text("editProfile.title.website", comment: "Website")
            } footer: {
                HStack {
                    Spacer()
                    Text("\(self.website.count)/\(self.websiteMaxLength)")
                }
            }
            
            Section {
                Toggle("editProfile.title.privateAccount", isOn: $isPrivate)
            } footer: {
                Text("editProfile.title.privateAccountInfo", comment: "Private account info")
            }

        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ActionButton(showLoader: true) {
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
            self.website = self.account.website ?? String.empty()
            self.isPrivate = self.account.locked
            
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
    
    @MainActor
    private func saveProfile() async {
        do {
            _ = try await self.client.accounts?.update(displayName: self.displayName,
                                                       bio: self.bio,
                                                       website: self.website,
                                                       locked: self.isPrivate,
                                                       image: nil)

            if let avatarData = self.avatarData {
                _ = try await self.client.accounts?.avatar(image: avatarData)
                
                if let accountData = AccountDataHandler.shared.getAccountData(accountId: self.account.id) {
                    accountData.avatarData = avatarData
                    self.applicationState.account?.avatarData = avatarData
                    CoreDataHandler.shared.save()
                }
            }
            
            let savedAccount = try await self.client.accounts?.account(withId: self.account.id)
            // self.applicationState.account?.avatar,
            self.applicationState.updatedProfile = savedAccount

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
                .resized(to: .init(width: 800, height: 800))
                .getJpegData() else {
                return
            }

            withAnimation(.linear) {
                self.avatarData = data
            }
            
            self.saveDisabled = false
        } catch {
            ErrorService.shared.handle(error, message: "editProfile.error.loadingAvatarFailed", showToastr: true)
        }
    }
}
