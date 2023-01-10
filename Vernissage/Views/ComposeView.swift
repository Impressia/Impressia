//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

struct ComposeView: View {
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.dismiss) private var dismiss
    
    @Binding var status: Status?
    @State private var text = ""
    
    private let contentWidth = Int(UIScreen.main.bounds.width) - 50
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack (alignment: .leading){
                    if let accountData = applicationState.accountData {
                        HStack {
                            UsernameRow(
                                accountAvatar: accountData.avatar,
                                accountDisplayName: accountData.displayName,
                                accountUsername: accountData.username,
                                cachedAvatar: CacheAvatarService.shared.getImage(for: accountData.id))
                            Spacer()
                        }
                        .padding(8)
                    }
                    
                    TextField("Type what's on your mind", text: $text)
                        .padding(8)
                    
                    if let status = self.status {
                        HStack (alignment: .top) {

                            AsyncImage(url: status.account?.avatar) { image in
                                image
                                    .resizable()
                                    .clipShape(Circle())
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .foregroundColor(.mainTextColor)
                            }
                            .frame(width: 32.0, height: 32.0)

                            VStack (alignment: .leading, spacing: 0) {
                                HStack (alignment: .top) {
                                    Text(self.getUserName(status: status))
                                        .foregroundColor(.mainTextColor)
                                        .font(.footnote)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                }
                                
                                HTMLFormattedText(status.content, withFontSize: 14, andWidth: contentWidth)
                                    .padding(.top, -4)
                                    .padding(.leading, -4)
                            }
                        }
                        .padding(8)
                        .background(Color.selectedRowColor)
                    }
                    
                    Spacer()
                }
            }
            .frame(alignment: .topLeading)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Publish")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .navigationBarTitle(Text("Compose"), displayMode: .inline)
        }
    }
    
    private func getUserName(status: Status) -> String {
        return status.account?.displayName ?? status.account?.acct ?? status.account?.username ?? ""
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ComposeView(status: .constant(Status(id: "", content: "", application: Application(name: ""))))
    }
}
