//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import PixelfedKit

extension Client {
    public class Reports: BaseClient {
        public func report(objectType: Report.ObjectType, objectId: EntityId, reportType: Report.ReportType) async throws {
            try await pixelfedClient.report(objectType: objectType, objectId: objectId, reportType: reportType)
        }
    }
}
