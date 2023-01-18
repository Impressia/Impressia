//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation

public struct Emoji: Codable {
    public let shortcode: String
    public let url: URL
    public let staticUrl: URL
    public let visibleInPicker: Bool

    private enum CodingKeys: String, CodingKey {
        case shortcode
        case url
        case staticUrl = "static_url"
        case visibleInPicker = "visible_in_picker"
    }
}
