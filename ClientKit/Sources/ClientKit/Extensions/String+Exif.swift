//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

public extension String {
    func calculateExifNumber() -> String? {
        guard self.contains("/") else {
            return self
        }

        let parts = self.split(separator: "/")
        guard parts.count == 2 else {
            return nil
        }

        if let first = Int(parts[0]), let second = Int(parts[1]) {
            let calculated = Double(first) / Double(second)
            return String(calculated.rounded(toPlaces: 2))
        }

        return nil
    }
}
