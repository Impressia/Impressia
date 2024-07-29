//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

class ColumnData<T>: Identifiable where T: Identifiable, T: Hashable, T: Sizable {
    public let id = UUID().uuidString
    public var data: [T] = []
    public var height: Double = 0.0
}
