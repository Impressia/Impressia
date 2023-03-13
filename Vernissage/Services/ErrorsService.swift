//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation
import PixelfedKit

public class ErrorService {
    public static let shared = ErrorService()
    private init() { }
    
    public func handle(_ error: Error, message: String, showToastr: Bool = false) {
        if showToastr {
            switch error {
            case is NetworkError, is URLError:
                ToastrService.shared.showError(title: message, subtitle: error.localizedDescription)
            default:
                ToastrService.shared.showError(subtitle: message)
            }
        }
        
        let localizedMessage = NSLocalizedString(message, comment: "Error message")
        print("Error ['\(localizedMessage)']: \(error.localizedDescription)")
    }
}
