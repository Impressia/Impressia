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

        // API reports returns bad request even if data is correct.
        let (data, response) = try await urlSession.data(for: request)

        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            if let json = String(data: data, encoding: .utf8) {
                if json.contains("ERROR_NO_SELF_REPORTS") {
                    throw ReportError.noSelfReports
                } else if json.contains("ERROR_INVALID_OBJECT_ID") {
                    throw ReportError.invalidObjectId
                } else if json.contains("ERROR_REPORT_DUPLICATE") {
                    throw ReportError.duplicate
                } else if json.contains("ERROR_INVALID_PARAMS") {
                    throw ReportError.invalidParameters
                } else if json.contains("ERROR_TYPE_INVALID") {
                    throw ReportError.invalidType
                } else if json.contains("ERROR_REPORT_OBJECT_TYPE_INVALID") {
                    throw ReportError.invalidObject
                }
            }

            throw NetworkError.notSuccessResponse(response)
        }

        return try JSONDecoder().decode(Report.self, from: data)
    }
}
