//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import SwiftUI

struct InteractionRow: View {
    @EnvironmentObject var applicationState: ApplicationState
    @State var statusId = ""
    @State var repliesCount = 0
    @State var reblogged = false
    @State var reblogsCount = 0
    @State var favourited = false
    @State var favouritesCount = 0
    @State var bookmarked = false
        
    var onNewStatus: (() -> Void)?
    
    var body: some View {
        HStack (alignment: .top) {
            ActionButton {
                onNewStatus?()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "message")
                    Text("\(repliesCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            ActionButton {
                do {
                    let status = self.reblogged
                        ? try await StatusService.shared.unboost(statusId: self.statusId, accountData: self.applicationState.accountData)
                        : try await StatusService.shared.boost(statusId: self.statusId, accountData: self.applicationState.accountData)

                    if let status {
                        self.reblogsCount = status.reblogsCount == self.reblogsCount
                            ? status.reblogsCount + 1
                            : status.reblogsCount

                        self.reblogged = status.reblogged
                    }
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: self.reblogged ? "paperplane.fill" : "paperplane")
                    Text("\(self.reblogsCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            ActionButton {
                do {
                    let status = self.favourited
                        ? try await StatusService.shared.unfavourite(statusId: self.statusId, accountData: self.applicationState.accountData)
                        : try await StatusService.shared.favourite(statusId: self.statusId, accountData: self.applicationState.accountData)

                    if let status {
                        self.favouritesCount = status.favouritesCount == self.favouritesCount
                            ? status.favouritesCount + 1
                            : status.favouritesCount

                        self.favourited = status.favourited
                    }
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: self.favourited ? "hand.thumbsup.fill" : "hand.thumbsup")
                    Text("\(self.favouritesCount)")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            ActionButton {
                do {
                    _ = self.bookmarked
                        ? try await StatusService.shared.unbookmark(statusId: self.statusId, accountData: self.applicationState.accountData)
                        : try await StatusService.shared.bookmark(statusId: self.statusId, accountData: self.applicationState.accountData)

                    self.bookmarked.toggle()
                } catch {
                    print("Error \(error.localizedDescription)")
                }
            } label: {
                Image(systemName: self.bookmarked ? "bookmark.fill" : "bookmark")
            }
            
            Spacer()
            
            ActionButton {
                // TODO: Share.
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
        }
        .font(.title3)
        .fontWeight(.semibold)
    }
}

struct InteractionRow_Previews: PreviewProvider {
    static var previews: some View {
        InteractionRow()
            .previewLayout(.fixed(width: 300, height: 70))
    }
}
