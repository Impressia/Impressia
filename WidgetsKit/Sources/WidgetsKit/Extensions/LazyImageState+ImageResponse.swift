//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import Nuke
import NukeUI

public extension LazyImageState {
    var imageResponse: ImageResponse? {
        if case .success(let imageResponse) = result {
            return imageResponse
        }
        return nil
    }
}
