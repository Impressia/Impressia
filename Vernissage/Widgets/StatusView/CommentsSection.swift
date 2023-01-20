//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI
import MastodonKit

struct CommentsSection: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var applicationState: ApplicationState

    @State public var statusId: String
    var onNewStatus: ((_ context: StatusViewModel) -> Void)?
    
    @State private var commentViewModels: [CommentViewModel]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let commentViewModels {
                ForEach(commentViewModels, id: \.status.id) { commentViewModel in
                    VStack(alignment: .leading, spacing: 0) {

                        if commentViewModel.showDivider {
                            Divider()
                                .frame(height: 1)
                                .overlay(Color.placeholderText.opacity(0.3))
                                .padding(0)
                        }
                                                
                        CommentBody(statusViewModel: commentViewModel.status)
                        
                        if self.applicationState.showInteractionStatusId == commentViewModel.status.id {
                            VStack (alignment: .leading, spacing: 0) {
                                InteractionRow(statusViewModel: commentViewModel.status) {
                                    self.onNewStatus?(commentViewModel.status)
                                }
                                .foregroundColor(self.getInteractionRowTextColor())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .background(Color.lightGrayColor.opacity(0.5))
                            .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
            } else {
                HStack {
                    Spacer()
                    LoadingIndicator()
                    Spacer()
                }
            }
        }
        .task {
            do {
                if let accountData = applicationState.accountData {
                    self.commentViewModels = try await TimelineService.shared.getComments(for: statusId, and: accountData)
                }
            } catch {
                ErrorService.shared.handle(error, message: "Comments cannot be downloaded.", showToastr: !Task.isCancelled)
            }
        }
    }
    
    private func getInteractionRowTextColor() -> Color {
        return self.colorScheme == .dark ? Color.black : Color.white
    }
}

struct CommentsSection_Previews: PreviewProvider {
    static var previews: some View {
        CommentsSection(statusId: "")
    }
}
