//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import PixelfedKit
import ClientKit
import ServicesKit
import WidgetsKit
import EnvironmentKit

struct UserProfileHeaderView: View {
    @EnvironmentObject private var applicationState: ApplicationState
    @EnvironmentObject private var client: Client
    @EnvironmentObject private var routerPath: RouterPath

    @State var account: Account
    @ObservedObject var relationship = RelationshipModel()
    @Binding var boostsDisabled: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
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

                Spacer()
            }

            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(account.displayNameWithoutEmojis)
                        .foregroundColor(.mainTextColor)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("@\(account.acct)")
                        .foregroundColor(.customGrayColor)
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

            self.accountRelationshipPanel()

            Text(String(format: NSLocalizedString("userProfile.title.joined", comment: "Joined"), account.createdAt.toRelative(.isoDateTimeMilliSec)))
                .foregroundColor(.customGrayColor.opacity(0.5))
                .font(.footnote)
        }
        .padding([.top, .leading, .trailing])
    }

    @ViewBuilder
    private func accountRelationshipPanel() -> some View {
        if self.relationship.followedBy || self.relationship.muting || self.relationship.blocking || self.boostsDisabled {
            HStack(alignment: .top) {
                if self.relationship.followedBy {
                    TagWidget(value: "userProfile.title.followsYou", color: .secondary, systemImage: "person.crop.circle.badge.checkmark")
                }

                if self.relationship.muting {
                    TagWidget(value: "userProfile.title.muted", color: .accentColor, systemImage: "message.and.waveform.fill")
                }
                
                if self.boostsDisabled {
                    TagWidget(value: "userProfile.title.boostedStatusesMuted", color: .accentColor, image: "custom.rocket.fill")
                }

                if self.relationship.blocking {
                    TagWidget(value: "userProfile.title.blocked", color: .dangerColor, systemImage: "hand.raised.fill")
                }
                
                Spacer()
            }
            .transition(.opacity)
        }
    }

    @ViewBuilder
    private func otherAccountActionButtons() -> some View {
        ActionButton {
            await onRelationshipButtonTap()
        } label: {
            HStack {
                Image(systemName: relationship.following == true ? "person.badge.minus" : "person.badge.plus")
                Text(self.getRelationshipActionText(), comment: "Follow/unfollow actions")
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(self.getTintColor())
    }

    private func getRelationshipActionText() -> LocalizedStringKey {
        let relationshipAction = self.relationship.getRelationshipAction(account: self.account)

        switch relationshipAction {
        case .follow:
            return "userProfile.title.follow"
        case .cancelRequestFollow:
            return "userProfile.title.cancelRequestFollow"
        case .requestFollow:
            return "userProfile.title.requestFollow"
        case .unfollow:
            return "userProfile.title.unfollow"
        }
    }

    private func getTintColor() -> Color {
        let relationshipAction = self.relationship.getRelationshipAction(account: self.account)

        switch relationshipAction {
        case .follow, .requestFollow:
            return .accentColor
        case .cancelRequestFollow, .unfollow:
            return .dangerColor
        }
    }

    private func onRelationshipButtonTap() async {
        do {
            let relationshipAction = self.relationship.getRelationshipAction(account: self.account)

            switch relationshipAction {
            case .follow, .requestFollow:
                if let relationship = try await self.client.accounts?.follow(account: self.account.id) {
                    self.relationship.update(relationship: relationship)
                }
            case .cancelRequestFollow, .unfollow:
                if let relationship = try await self.client.accounts?.unfollow(account: self.account.id) {
                    self.relationship.update(relationship: relationship)
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "userProfile.error.relationship", showToastr: true)
        }
    }
}
