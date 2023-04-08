//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit
import EnvironmentKit
import WidgetsKit

struct CommentsSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var applicationState: ApplicationState
    @EnvironmentObject var client: Client

    @State public var statusId: String
    @State private var commentViewModels: [CommentModel]?

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

                        CommentBodyView(statusViewModel: commentViewModel.status)

                        if self.applicationState.showInteractionStatusId == commentViewModel.status.id {
                            VStack(alignment: .leading, spacing: 0) {
                                InteractionRow(statusModel: commentViewModel.status)
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
        .onChange(of: self.applicationState.newComment) { _ in
            self.commentViewModels = nil
            Task {
                await self.loadComments()
            }
        }
        .task {
            await self.loadComments()
        }
    }

    private func getInteractionRowTextColor() -> Color {
        return self.colorScheme == .dark ? Color.black : Color.white
    }

    private func loadComments() async {
        do {
            self.commentViewModels = try await self.client.statuses?.comments(to: statusId) ?? []
        } catch {
            ErrorService.shared.handle(error, message: "status.error.loadingCommentsFailed", showToastr: !Task.isCancelled)
        }
    }
}
