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
    @Environment(ApplicationState.self) var applicationState
    @Environment(Client.self) var client

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
                                InteractionRow(statusModel: commentViewModel.status) {
                                    self.reloadComments()
                                }
                                .foregroundColor(self.getInteractionRowTextColor())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .background(Color.customGrayColor.opacity(0.5))
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
        .onChange(of: self.applicationState.latestPublishedStatusId) {
            self.reloadComments()
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
            let comments = try await self.client.statuses?.comments(to: statusId) ?? []
            withAnimation {
                self.commentViewModels = comments
            }
        } catch {
            ErrorService.shared.handle(error, message: "status.error.loadingCommentsFailed", showToastr: !Task.isCancelled)
        }
    }
    
    private func reloadComments() {
        withAnimation {
            self.commentViewModels = nil
        }

        // We have to download status after some time (when we ask strigt away we don't have ne comment in the list).
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Task { @MainActor in
                await self.loadComments()
            }
        }
    }
}
