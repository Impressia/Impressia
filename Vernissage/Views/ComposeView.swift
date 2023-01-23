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
    
    @State var statusViewModel: StatusViewModel?
    @State private var text = String.empty()

    @FocusState private var focusedField: FocusField?
    
    private let contentWidth = Int(UIScreen.main.bounds.width) - 50
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack (alignment: .leading){
                    if let accountData = applicationState.accountData {
                        HStack {
                            UsernameRow(
                                accountId: accountData.id,
                                accountAvatar: accountData.avatar,
                                accountDisplayName: accountData.displayName,
                                accountUsername: accountData.username)
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
                            UserAvatar(accountId: status.account.id, accountAvatar: status.account.avatar, width: 32, height: 32)

                            VStack (alignment: .leading, spacing: 0) {
                                HStack (alignment: .top) {
                                    Text(statusViewModel?.account.displayNameWithoutEmojis ?? "")
                                        .foregroundColor(.mainTextColor)
                                        .font(.footnote)
                                        .fontWeight(.bold)

                                    Spacer()
                                }

                                MarkdownFormattedText(status.content.asMarkdown, withFontSize: 14, andWidth: contentWidth)
                                    .environment(\.openURL, OpenURLAction { url in .handled })
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
                            ToastrService.shared.showSuccess("Status published", imageSystemName: "message.fill")
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
            ErrorService.shared.handle(error, message: "Error during post status.", showToastr: true)
        }
    }
}
