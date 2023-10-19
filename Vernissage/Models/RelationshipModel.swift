//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import SwiftUI
import Foundation
import PixelfedKit

@Observable public class RelationshipModel {
    enum RelationshipAction {
        case follow
        case unfollow
        case requestFollow
        case cancelRequestFollow
    }

    /// The account ID.
    public var id: EntityId

    /// Are you followed by this user?
    public var followedBy: Bool

    /// Is this user blocking you?
    public var blockedBy: Bool

    /// Are you muting notifications from this user?
    public var mutingNotifications: Bool

    /// Do you have a pending follow request for this user?
    public var requested: Bool

    /// Are you receiving this user’s boosts in your home timeline?
    public var showingReblogs: Bool

    /// Have you enabled notifications for this user?
    public var notifying: Bool

    /// Are you blocking this user’s domain?
    public var domainBlocking: Bool

    /// Are you featuring this user on your profile?
    public var endorsed: Bool

    /// Which languages are you following from this user? Array of String (ISO 639-1 language two-letter code).
    public var languages: [String]?

    /// This user’s profile bio.
    public var note: String?

    /// Are you following this user?
    public var following: Bool

    /// Are you blocking this user?
    public var blocking: Bool

    /// Are you muting this user?
    public var muting: Bool

    public init() {
        self.id = ""
        self.following = false
        self.followedBy = false
        self.blocking = false
        self.blockedBy = false
        self.muting = false
        self.mutingNotifications = false
        self.requested = false
        self.showingReblogs = false
        self.notifying = false
        self.domainBlocking = false
        self.endorsed = false
        self.note = nil
        self.languages = []
    }

    public init(relationship: Relationship) {
        self.id = relationship.id
        self.following = relationship.following
        self.followedBy = relationship.followedBy
        self.blocking = relationship.blocking
        self.blockedBy = relationship.blockedBy
        self.muting = relationship.muting
        self.mutingNotifications = relationship.mutingNotifications
        self.requested = relationship.requested
        self.showingReblogs = relationship.showingReblogs
        self.notifying = relationship.notifying
        self.domainBlocking = relationship.domainBlocking
        self.endorsed = relationship.endorsed
        self.languages = relationship.languages
        self.note = relationship.note
    }
}

extension RelationshipModel {
    public func update(relationship: Relationship) {
        self.id = relationship.id
        self.following = relationship.following
        self.followedBy = relationship.followedBy
        self.blocking = relationship.blocking
        self.blockedBy = relationship.blockedBy
        self.muting = relationship.muting
        self.mutingNotifications = relationship.mutingNotifications
        self.requested = relationship.requested
        self.showingReblogs = relationship.showingReblogs
        self.notifying = relationship.notifying
        self.domainBlocking = relationship.domainBlocking
        self.endorsed = relationship.endorsed
        self.languages = relationship.languages
        self.note = relationship.note
    }

    public func update(relationship: RelationshipModel) {
        self.id = relationship.id
        self.following = relationship.following
        self.followedBy = relationship.followedBy
        self.blocking = relationship.blocking
        self.blockedBy = relationship.blockedBy
        self.muting = relationship.muting
        self.mutingNotifications = relationship.mutingNotifications
        self.requested = relationship.requested
        self.showingReblogs = relationship.showingReblogs
        self.notifying = relationship.notifying
        self.domainBlocking = relationship.domainBlocking
        self.endorsed = relationship.endorsed
        self.languages = relationship.languages
        self.note = relationship.note
    }
}

extension RelationshipModel {
    func haveAccessToPhotos(account: Account) -> Bool {
        return !account.locked || (account.locked && self.following)
    }

    func getRelationshipAction(account: Account) -> RelationshipAction {
        if self.following {
            return .unfollow
        }

        if self.requested {
            return .cancelRequestFollow
        }

        if account.locked {
            return .requestFollow
        }

        return .follow
    }
}
