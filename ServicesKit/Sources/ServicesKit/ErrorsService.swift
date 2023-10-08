//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import OSLog
import EnvironmentKit
import PixelfedKit

public class ErrorService {
    public static let shared = ErrorService()
    private init() { }

    public func handle(_ error: Error, message: String, showToastr: Bool = false) {
        let localizedMessage = NSLocalizedString(message, comment: "Error message")

        if showToastr {
            switch error {
            case is LocalizedError:
                ToastrService.shared.showError(title: message, subtitle: error.localizedDescription)
            default:
                ToastrService.shared.showError(subtitle: localizedMessage)
            }
        }

        Logger.main.error("Error ['\(localizedMessage)']: \(error.localizedDescription)")
        Logger.main.error("Error ['\(localizedMessage)']: \(error)")
    }
}
