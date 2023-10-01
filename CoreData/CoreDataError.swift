//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import OSLog
import EnvironmentKit

public class CoreDataError {
    public static let shared = CoreDataError()
    private init() { }

    public func handle(_ error: Error, message: String) {
        Logger.main.error("Error ['\(message)']: \(error.localizedDescription)")
    }
}
