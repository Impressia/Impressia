//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import PixelfedKit

struct EditProfileView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    @Environment(\.dismiss) private var dismiss
    
    @State private var saveDisabled = false
    @State var displayName: String = ""
    @State var bio: String = ""
    
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
                            UserAvatar(accountAvatar: account.avatar, size: .profile)
                            BottomRight {
                                Button {
                                    
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
                    .lineLimit(4, reservesSpace: true)
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
    }
    
    private func saveProfile() async {
        do {
            _ = try await self.client.accounts?.update(displayName: self.displayName, bio: self.bio, image: nil)
            ToastrService.shared.showSuccess("editProfile.title.accountSaved", imageSystemName: "person.crop.circle")
            dismiss()
        } catch {
            ErrorService.shared.handle(error, message: "editProfile.error.saveAccountFailed", showToastr: true)
        }
    }
}
