//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import OSLog

public extension Logger {
    /// Using your bundle identifier is a great way to ensure a unique identifier.
    private static var subsystem = Bundle.main.bundleIdentifier ?? "dev.mczachurski.vernissage"

    /// Logs the main informations.
    static let main = Logger(subsystem: subsystem, category: "main")
}
