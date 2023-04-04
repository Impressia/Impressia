//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension PixelfedClientAuthenticated {
    func report(objectType: Report.ObjectType,
                objectId: EntityId,
                reportType: Report.ReportType) async throws -> Report {
        let request = try Self.request(
            for: baseURL,
            target: Pixelfed.Reports.report(objectType, objectId, reportType),
            withBearerToken: token
        )

        return try await downloadJson(Report.self, request: request)
    }
}
