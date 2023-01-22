//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a user-defined filter for determining which statuses should not be shown to the user.
public struct Filter: Codable {
    public enum FilterContext: String, Codable {
        /// Home timeline and lists.
        case home = "home"
        /// Notifications timeline.
        case notifications = "notifications"
        /// Public timelines.
        case `public` = "public"
        /// Expanded thread of a detailed status.
        case thread = "thread"
        /// When viewing a profile.
        case account = "account"
    }
    
    public enum FilterAction: String, Codable {
        /// Show a warning that identifies the matching filter by title, and allow the user to expand the filtered status.
        /// This is the default (and unknown values should be treated as equivalent to warn).
        case warn = "warn"
        /// do not show this status if it is received
        case hide = "hide"
    }

    /// The ID of the Filter in the database.
    public let id: EntityId
    
    /// A title given by the user to name the filter.
    public let title: String
    
    /// The contexts in which the filter should be applied.
    public let context: FilterContext
    
    /// When the filter should no longer be applied. NULLABLE String (ISO 8601 Datetime), or null if the filter does not expire.
    public let expiresAt: String?
    
    /// The action to be taken when a status matches this filter.
    public let filterAction: FilterAction
    
    /// The keywords grouped under this filter.
    public let keywords: [FilterKeyword]
    
    /// The statuses grouped under this filter.
    public let statuses: [FilterStatus]
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case context
        case expiresAt = "expires_at"
        case filterAction = "filter_action"
        case keywords
        case statuses
    }
}
