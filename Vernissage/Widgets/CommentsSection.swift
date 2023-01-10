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
    @State public var withDivider = true
    @State private var context: Context?
    
    var onNewStatus: ((_ context: StatusViewModel) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let context = context {
                ForEach(context.descendants.toStatusViewModel(), id: \.id) { statusViewModel in
                    VStack(alignment: .leading, spacing: 0) {

                        if withDivider {
                            Divider()
                                .foregroundColor(.mainTextColor)
                                .padding(0)
                        }
                                                
                        CommentBody(statusViewModel: statusViewModel)
                        
                        if self.applicationState.showInteractionStatusId == statusViewModel.id {
                            VStack (alignment: .leading, spacing: 0) {
                                InteractionRow(statusViewModel: statusViewModel) {
                                    self.onNewStatus?(statusViewModel)
                                }
                                .foregroundColor(self.getInteractionRowTextColor())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .background(Color.lightGrayColor.opacity(0.5))
                            .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                        }
                        
                        CommentsSection(statusId: statusViewModel.id, withDivider: false)  { context in
                            self.onNewStatus?(context)
                        }
                    }
                }
            }
        }
        .task {
            do {
                if let accountData = applicationState.accountData {
                    self.context = try await TimelineService.shared.getComments(
                        for: statusId,
                        and: accountData)
                }
            } catch {
                print("Error \(error.localizedDescription)")
            }
        }
    }
    
    private func getInteractionRowTextColor() -> Color {
        return self.colorScheme == .dark ? Color.black : Color.white
    }
}

struct CommentsSection_Previews: PreviewProvider {
    static var previews: some View {
        CommentsSection(statusId: "", withDivider: true)
    }
}
