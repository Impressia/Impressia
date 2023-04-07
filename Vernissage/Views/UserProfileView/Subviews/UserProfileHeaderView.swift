//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit

struct UserProfileHeaderView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    @EnvironmentObject private var routerPath: RouterPath

    @State var account: Account
    @ObservedObject var relationship = RelationshipModel()

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Spacer()

                if self.relationship.muting == true {
                    TagWidget(value: "Muted", color: .accentColor, systemImage: "message.and.waveform.fill")
                }

                if self.relationship.blocking == true {
                    TagWidget(value: "Blocked", color: .dangerColor, systemImage: "hand.raised.fill")
                }
            }

            HStack(alignment: .center) {
                UserAvatar(accountAvatar: account.avatar, size: .profile)

                Spacer()

                VStack(alignment: .center) {
                    Text("\(account.statusesCount)")
                        .font(.title3)
                    Text("userProfile.title.posts", comment: "Posts")
                        .font(.subheadline)
                        .opacity(0.6)
                }

                Spacer()

                NavigationLink(value: RouteurDestinations.accounts(listType: .followers(entityId: account.id))) {
                    VStack(alignment: .center) {
                        Text("\(account.followersCount)")
                            .font(.title3)
                        Text("userProfile.title.followers", comment: "Followers")
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }.foregroundColor(.mainTextColor)

                Spacer()

                NavigationLink(value: RouteurDestinations.accounts(listType: .following(entityId: account.id))) {
                    VStack(alignment: .center) {
                        Text("\(account.followingCount)")
                            .font(.title3)
                        Text("userProfile.title.following", comment: "Following")
                            .font(.subheadline)
                            .opacity(0.6)
                    }
                }.foregroundColor(.mainTextColor)
            }

            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(account.displayNameWithoutEmojis)
                        .foregroundColor(.mainTextColor)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("@\(account.acct)")
                        .foregroundColor(.lightGrayColor)
                        .font(.subheadline)
                }

                Spacer()

                if self.applicationState.account?.id != self.account.id {
                    self.otherAccountActionButtons()
                }
            }

            if let note = account.note, !note.asMarkdown.isEmpty {
                MarkdownFormattedText(note.asMarkdown)
                    .font(.subheadline)
                    .environment(\.openURL, OpenURLAction { url in
                        routerPath.handle(url: url)
                    })
                    .padding(.vertical, 4)
            }

            if let website = account.website, let url = URL(string: website) {
                HStack {
                    Image(systemName: "link")
                    Link(website, destination: url)
                    Spacer()
                }
                .padding(.bottom, 2)
                .font(.footnote)
            }

            Text(String(format: NSLocalizedString("userProfile.title.joined", comment: "Joined"), account.createdAt.toRelative(.isoDateTimeMilliSec)))
                .foregroundColor(.lightGrayColor.opacity(0.5))
                .font(.footnote)
        }
        .padding()
    }

    @ViewBuilder
    private func otherAccountActionButtons() -> some View {
        ActionButton {
            await onRelationshipButtonTap()
        } label: {
            HStack {
                Image(systemName: relationship.following == true ? "person.badge.minus" : "person.badge.plus")
                Text(relationship.following == true
                     ? "userProfile.title.unfollow"
                     : (relationship.followedBy == true ? "userProfile.title.followBack" : "userProfile.title.follow"), comment: "Follow/unfollow actions")
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(relationship.following == true ? .dangerColor : .accentColor)
    }

    private func onRelationshipButtonTap() async {
        do {
            if self.relationship.following == true {
                if let relationship = try await self.client.accounts?.unfollow(account: self.account.id) {
                    self.relationship.following = relationship.following
                }
            } else {
                if let relationship = try await self.client.accounts?.follow(account: self.account.id) {
                    self.relationship.following = relationship.following
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "userProfile.error.relationship", showToastr: true)
        }
    }
}
