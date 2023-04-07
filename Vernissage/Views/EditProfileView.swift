//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import PhotosUI
import SwiftUI
import PixelfedKit
import ClientKit
import HTMLString

struct EditProfileView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    @Environment(\.dismiss) private var dismiss

    @State private var account: Account?
    @State private var photosPickerVisible = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var saveDisabled = false
    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var website: String = ""
    @State private var isPrivate = false
    @State private var avatarData: Data?
    @State private var state: ViewState = .loading

    private let bioMaxLength = 200
    private let displayNameMaxLength = 30
    private let websiteMaxLength = 120

    var body: some View {
        self.mainBody()
            .navigationTitle("editProfile.navigationBar.title")
    }

    @ViewBuilder
    private func mainBody() -> some View {
        switch state {
        case .loading:
            LoadingIndicator()
                .task {
                    await self.loadData()
                }
        case .loaded:
            if let account = self.account {
                self.editForm(account: account)
            } else {
                NoDataView(imageSystemName: "person.crop.circle", text: "editProfile.error.noProfileData")
            }
        case .error(let error):
            ErrorView(error: error) {
                self.state = .loading
                await self.loadData()
            }
            .padding()
        }
    }

    @ViewBuilder
    private func editForm(account: Account) -> some View {
        Form {
            self.avatarView(account: account)
            self.formView()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ActionButton(showLoader: true) {
                    await self.saveProfile(account: account)
                } label: {
                    Text("editProfile.title.save", comment: "Save")
                }
                .disabled(self.saveDisabled)
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            self.displayName = account.displayName ?? String.empty()
            self.website = account.website ?? String.empty()
            self.isPrivate = account.locked

            // Bio should be set from source property (which is plain text).
            if let note = account.source?.note {
                self.bio = note.removingHTMLEntities()
            } else {
                let markdownBio = account.note?.asMarkdown ?? String.empty()
                if let attributedString = try? AttributedString(markdown: markdownBio) {
                    self.bio = String(attributedString.characters)
                }
            }
        }
        .onChange(of: self.selectedItems) { _ in
            Task {
                await self.getAvatar()
            }
        }
        .photosPicker(isPresented: $photosPickerVisible,
                      selection: $selectedItems,
                      maxSelectionCount: 1,
                      matching: .images)
    }

    @ViewBuilder
    private func avatarView(account: Account) -> some View {
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

                Text("@\(account.acct)")
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
    }

    @ViewBuilder
    private func formView() -> some View {
        Section {
            TextField("", text: $displayName)
                .onChange(of: self.displayName, perform: { _ in
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
                .onChange(of: self.bio, perform: { _ in
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
                .onChange(of: self.website, perform: { _ in
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

    private func loadData() async {
        do {
            self.account = try await self.client.accounts?.pixelfedClient.verifyCredentials()
            self.state = .loaded
        } catch {
            if !Task.isCancelled {
                ErrorService.shared.handle(error, message: "editProfile.error.loadingAccountFailed", showToastr: true)
                self.state = .error(error)
            } else {
                ErrorService.shared.handle(error, message: "editProfile.error.loadingAccountFailed", showToastr: false)
            }
        }
    }

    @MainActor
    private func saveProfile(account: Account) async {
        do {
            _ = try await self.client.accounts?.update(displayName: self.displayName,
                                                       bio: self.bio,
                                                       website: self.website,
                                                       locked: self.isPrivate,
                                                       image: nil)

            if let avatarData = self.avatarData {
                _ = try await self.client.accounts?.avatar(image: avatarData)

                if let accountData = AccountDataHandler.shared.getAccountData(accountId: account.id) {
                    accountData.avatarData = avatarData
                    self.applicationState.account?.avatarData = avatarData
                    CoreDataHandler.shared.save()
                }
            }

            let savedAccount = try await self.client.accounts?.account(withId: account.id)
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
