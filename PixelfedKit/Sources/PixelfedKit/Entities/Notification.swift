//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents a notification of an event relevant to the user.
public struct Notification: Codable {
    public enum NotificationType: String, Codable {
        /// Someone mentioned you in their status.
        case mention = "mention"

        /// Someone boosted one of your statuses.
        case reblog = "reblog"

        /// Someone favourited one of your statuses.
        case favourite = "favourite"

        /// Someone followed you.
        case follow = "follow"

        /// Someone you enabled notifications for has posted a status.
        case status = "status"

        /// Someone requested to follow you.
        case followRequest = "follow_request"

        /// A poll you have voted in or created has ended.
        case poll = "poll"

        /// A status you interacted with has been edited.
        case update = "update"

        /// Someone signed up (optionally sent to admins).
        case adminSignUp = "admin.sign_up"

        /// A new report has been filed.
        case adminReport = "admin.report"
    }

    /// The id of the notification in the database.
    public let id: EntityId

    /// The type of event that resulted in the notification.
    public let type: NotificationType

    /// The timestamp of the notification. String (ISO 8601 Datetime).
    public let createdAt: String

    /// The account that performed the action that generated the notification.
    public let account: Account

    /// Status that was the object of the notification. Attached when type of the notification is favourite, reblog, status, mention, poll, or update.
    public let status: Status?

    /// Report that was the object of the notification. Attached when type of the notification is admin.report.
    public let report: Report?

    private enum CodingKeys: String, CodingKey {
        case id
        case type
        case createdAat = "created_at"
        case account
        case status
        case report
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(EntityId.self, forKey: .id)
        self.type = try container.decode(NotificationType.self, forKey: .type)
        self.createdAt = try container.decode(String.self, forKey: .createdAat)
        self.account = try container.decode(Account.self, forKey: .account)
        self.status = try? container.decodeIfPresent(Status.self, forKey: .status)
        self.report = try? container.decodeIfPresent(Report.self, forKey: .report)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(createdAt, forKey: .createdAat)
        try container.encode(account, forKey: .account)

        if let status {
            try container.encode(status, forKey: .status)
        }

        if let report {
            try container.encode(report, forKey: .report)
        }
    }
}
