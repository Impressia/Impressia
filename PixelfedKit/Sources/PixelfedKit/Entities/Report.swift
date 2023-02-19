//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Reports filed against users and/or statuses, to be taken action on by moderators.
public struct Report: Codable {
    public enum ReportCategoryTye: String, Codable {
        /// Unwanted or repetitive content
        case spam = "spam"
        /// A specific rule was violated
        case violation = "violation"
        /// Some other reason
        case other = "other"
    }
    
    /// The ID of the report in the database.
    public let id: EntityId
    
    /// Whether an action was taken yet.
    public let actionTaken: String?
    
    /// When an action was taken against the report. NULLABLE String (ISO 8601 Datetime) or null.
    public let actionTakenAt: String?
    
    /// The generic reason for the report.
    public let category: ReportCategoryTye
    
    /// The reason for the report.
    public let comment: String
    
    /// Whether the report was forwarded to a remote domain.
    public let forwarded: Bool

    /// When the report was created. String (ISO 8601 Datetime).
    public let createdAt: String
    
    /// List od statuses in the report.
    public let statusIds: [EntityId]?
    
    /// List of the rules in ther report.
    public let ruleIds: [EntityId]?
    
    /// The account that was reported.
    public let targetAccount: Account

    public enum CodingKeys: String, CodingKey {
        case id
        case actionTaken
        case actionTakenAt = "action_taken_at"
        case category
        case comment
        case forwarded
        case createdAt = "created_at"
        case statusIds = "status_ids"
        case ruleIds = "rule_ids"
        case targetAccount = "target_account"
    }
}
