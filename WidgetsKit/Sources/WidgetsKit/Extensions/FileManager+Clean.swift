//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import SwiftUI
import ServicesKit

public extension FileManager {
    func clearTmpDirectory() {
        do {
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let contentsOfDirectory = try contentsOfDirectory(atPath: temporaryDirectory.path)

            for file in contentsOfDirectory {
                let fileUrl = temporaryDirectory.appendingPathComponent(file)
                do {
                    try removeItem(atPath: fileUrl.path)
                } catch {
                    ErrorService.shared.handle(error, message: "global.error.errorDuringDeletingFileFromTmpDirectory")
                }
            }
        } catch {
            ErrorService.shared.handle(error, message: "global.error.errorDuringGettingTmpDirectoryContents")
        }
    }
}
