//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Reports filed against users and/or statuses, to be taken action on by moderators.
public struct Report: Codable {

    /// Type of report.
    public enum ReportType: String, Codable {
        case spam
        case sensitive
        case abusive
        case underage
        case violence
        case copyright
        case impersonation
        case scam
        case terrorism
    }

    /// Object type.
    public enum ObjectType: String, Codable {
        case post
        case user
    }

    public let objectType: Report.ObjectType
    public let objectId: EntityId
    public let type: Report.ReportType

    private enum CodingKeys: String, CodingKey {
        case objectType = "object_type"
        case objectId = "object_id"
        case type
    }
}
