//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct InteractionRow: View {
    @EnvironmentObject var applicationState: ApplicationState
    @ObservedObject public var statusData: StatusData

    var body: some View {
        HStack (alignment: .top) {
            Button {
                // TODO: Reply.
                UserFeedbackService.shared.send()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "message")
                    Text("\(statusData.repliesCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Button {
                Task {
                    do {
                        let status = self.statusData.reblogged
                            ? try await StatusService.shared.unboost(statusId: self.statusData.id, accountData: self.applicationState.accountData)
                            : try await StatusService.shared.boost(statusId: self.statusData.id, accountData: self.applicationState.accountData)

                        if let status {
                            self.statusData.reblogsCount = status.reblogsCount == self.statusData.reblogsCount
                                ? Int32(status.reblogsCount + 1)
                                : Int32(status.reblogsCount)

                            self.statusData.reblogged = status.reblogged
                            UserFeedbackService.shared.send()
                        }
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: statusData.reblogged ? "paperplane.fill" : "paperplane")
                    Text("\(statusData.reblogsCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Button {
                Task {
                    do {
                        let status = self.statusData.favourited
                            ? try await StatusService.shared.unfavourite(statusId: self.statusData.id, accountData: self.applicationState.accountData)
                            : try await StatusService.shared.favourite(statusId: self.statusData.id, accountData: self.applicationState.accountData)

                        if let status {
                            self.statusData.favouritesCount = status.favouritesCount == self.statusData.favouritesCount
                                ? Int32(status.favouritesCount + 1)
                                : Int32(status.favouritesCount)

                            self.statusData.favourited = status.favourited
                            UserFeedbackService.shared.send()
                        }
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: statusData.favourited ? "hand.thumbsup.fill" : "hand.thumbsup")
                    Text("\(statusData.favouritesCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            Button {
                Task {
                    do {
                        let status = self.statusData.bookmarked
                            ? try await StatusService.shared.unbookmark(statusId: self.statusData.id, accountData: self.applicationState.accountData)
                            : try await StatusService.shared.bookmark(statusId: self.statusData.id, accountData: self.applicationState.accountData)

                        self.statusData.bookmarked.toggle()
                        UserFeedbackService.shared.send()
                    } catch {
                        print("Error \(error.localizedDescription)")
                    }
                }
            } label: {
                Image(systemName: statusData.bookmarked ? "bookmark.fill" : "bookmark")
            }
            
            Spacer()
            
            Button {
                // TODO: Share.
                UserFeedbackService.shared.send()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .font(.title3)
        .fontWeight(.semibold)
        .foregroundColor(Color.accentColor)
    }
}

struct InteractionRow_Previews: PreviewProvider {
    static var previews: some View {
        InteractionRow(statusData: PreviewData.getStatus())
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
