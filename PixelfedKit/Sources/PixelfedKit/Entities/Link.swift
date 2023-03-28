//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation
import RegexBuilder

/// Link returned in header for paging feature/
public struct Link {
    
    /// Raw value of header link.
    public let rawLink: String
}

extension Link {
    public var maxId: String? {
        do {
            let regex = try Regex("max_id=[0-9]+")
            if let match = rawLink.firstMatch(of: regex) {
                return match.output.first?.substring?.replacingOccurrences(of: "max_id=", with: "")
            }
        } catch {
            return nil
        }

        return nil
    }
    
    public var minId: String? {
        do {
            let regex = try Regex("min_id=[0-9]+")
            if let match = rawLink.firstMatch(of: regex) {
                return match.output.first?.substring?.replacingOccurrences(of: "min_id=", with: "")
            }
        } catch {
            return nil
        }

        return nil
    }
}
