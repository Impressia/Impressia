//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import SwiftUI
import MastodonKit

struct ComposeView: View {
    enum FocusField: Hashable {
        case content
    }
    
    @EnvironmentObject var applicationState: ApplicationState
    @Environment(\.dismiss) private var dismiss
    
    @Binding var statusViewModel: StatusViewModel?
    @State private var text = ""

    @FocusState private var focusedField: FocusField?
    
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
                        .focused($focusedField, equals: .content)
                        .task {
                            self.focusedField = .content
                        }

                    if let status = self.statusViewModel {
                        HStack (alignment: .top) {

                            AsyncImage(url: status.account.avatar) { image in
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
                                    Text(self.getUserName(statusViewModel: status))
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
                        Task {
                            await self.publishStatus()
                            dismiss()
                        }
                    } label: {
                        Text("Publish")
                            .foregroundColor(.white)
                    }
                    .disabled(self.text.isEmpty)
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
    
    private func publishStatus() async {
        do {
            _ = try await StatusService.shared.new(
                status: Mastodon.Statuses.Components(inReplyToId: self.statusViewModel?.id, text: self.text),
                accountData: self.applicationState.accountData)
        } catch {
            print("Error \(error.localizedDescription)")
        }
    }
    
    private func getUserName(statusViewModel: StatusViewModel) -> String {
        return self.statusViewModel?.account.displayName ?? self.statusViewModel?.account.acct ?? self.statusViewModel?.account.username ?? ""
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        Text("")
        // ComposeView(status: .constant(Status(id: "", content: "", application: Application(name: ""))))
    }
}
