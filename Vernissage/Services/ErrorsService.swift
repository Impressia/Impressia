//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public class ErrorService {
    public static let shared = ErrorService()
    private init() { }
    
    public func handle(_ error: Error, message: String, showToastr: Bool = false) {
        if showToastr {
            ToastrService.shared.showError(subtitle: message)
        }
        
        print("Error: \(error.localizedDescription)")
    }
}
