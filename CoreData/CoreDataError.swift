//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation

public class CoreDataError {
    public static let shared = CoreDataError()
    private init() { }
    
    public func handle(_ error: Error, message: String) {
        print("Error ['\(message)']: \(error.localizedDescription)")
    }
}
