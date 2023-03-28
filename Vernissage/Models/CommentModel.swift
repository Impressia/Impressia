//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation

public struct CommentModel {
    var status: StatusModel
    var showDivider: Bool
}

extension CommentModel: Equatable {
    public static func == (lhs: CommentModel, rhs: CommentModel) -> Bool {
        return lhs.status.id == rhs.status.id
    }
}
