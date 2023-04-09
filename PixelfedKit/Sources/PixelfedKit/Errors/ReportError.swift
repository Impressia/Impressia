//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public enum ReportError: Error {
    case noSelfReports
    case invalidObjectId
    case duplicate
    case invalidParameters
    case invalidType
    case invalidObject
}

extension ReportError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noSelfReports:
            return NSLocalizedString("report.error.noSelfReports",
                                     bundle: Bundle.module,
                                     comment: "Self-reporting is not allowed.")
        case .invalidObjectId:
            return NSLocalizedString("report.error.invalidObjectId",
                                     bundle: Bundle.module,
                                     comment: "Incorrect object Id.")
        case .duplicate:
            return NSLocalizedString("report.error.duplicate",
                                     bundle: Bundle.module,
                                     comment: "The report has already been sent.")
        case .invalidParameters:
            return NSLocalizedString("report.error.invalidParameters",
                                     bundle: Bundle.module,
                                     comment: "Invalid report parameters.")
        case .invalidType:
            return NSLocalizedString("report.error.invalidType",
                                     bundle: Bundle.module,
                                     comment: "Invalid report type.")
        case .invalidObject:
            return NSLocalizedString("report.error.invalidObject",
                                     bundle: Bundle.module,
                                     comment: "Invalid object type.")
        }
    }
}
