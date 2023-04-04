//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

extension Pixelfed {
    public enum Reports {
        case report(Report.ObjectType, EntityId, Report.ReportType)
    }
}

extension Pixelfed.Reports: TargetType {
    private struct Request: Encodable {
        let objectType: Report.ObjectType
        let objectId: EntityId
        let reportType: Report.ReportType

        private enum CodingKeys: String, CodingKey {
            case objectType = "object_type"
            case objectId = "object_id"
            case reportType = "report_type"
        }

        func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<Pixelfed.Reports.Request.CodingKeys> = encoder.container(keyedBy: Pixelfed.Reports.Request.CodingKeys.self)
            try container.encode(self.objectType, forKey: Pixelfed.Reports.Request.CodingKeys.objectType)
            try container.encode(self.objectId, forKey: Pixelfed.Reports.Request.CodingKeys.objectId)
            try container.encode(self.reportType, forKey: Pixelfed.Reports.Request.CodingKeys.reportType)
        }
    }

    private var apiPath: String { return "/api/v1.1/report" }

    /// The path to be appended to `baseURL` to form the full `URL`.
    public var path: String {
        switch self {
        case .report:
            return "\(apiPath)"
        }
    }

    /// The HTTP method used in the request.
    public var method: Method {
        switch self {
        case .report:
            return .post
        }
    }

    /// The parameters to be incoded in the request.
    public var queryItems: [(String, String)]? {
        nil
    }

    public var headers: [String: String]? {
        [:].contentTypeApplicationJson
    }

    public var httpBody: Data? {
        switch self {
        case .report(let objectType, let objectId, let reportType):
            return try? JSONEncoder().encode(
                Request(objectType: objectType, objectId: objectId, reportType: reportType)
            )
        }
    }
}
