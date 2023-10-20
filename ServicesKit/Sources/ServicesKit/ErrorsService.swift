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

    public func handle(_ error: Error, message: LocalizedStringResource, showToastr: Bool = false) {
        let localizedMessage = NSLocalizedString(message.key, comment: "Error message")

        if showToastr {
            switch error {
            case is LocalizedError:
                ToastrService.shared.showError(title: message, subtitle: error.localizedDescription)
            default:
                ToastrService.shared.showError(title: "", subtitle: localizedMessage)
            }
        }

        Logger.main.error("Error ['\(localizedMessage)']: \(error.localizedDescription)")
        Logger.main.error("Error ['\(localizedMessage)']: \(error)")
    }
    
    public func handle(_ error: Error, localizedMessage: String, showToastr: Bool = false) {
        if showToastr {
            switch error {
            case is LocalizedError:
                ToastrService.shared.showError(localizedMessage: localizedMessage, subtitle: error.localizedDescription)
            default:
                ToastrService.shared.showError(title: "", subtitle: localizedMessage)
            }
        }

        Logger.main.error("Error ['\(localizedMessage)']: \(error.localizedDescription)")
        Logger.main.error("Error ['\(localizedMessage)']: \(error)")
    }
}
