//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation

/// Represents a custom emoji.
public struct CustomEmoji: Codable {

    /// The name of the custom emoji.
    public let shortcode: String

    /// A link to the custom emoji.
    public let url: URL

    /// A link to a static copy of the custom emoji.
    public let staticUrl: URL

    /// Whether this Emoji should be visible in the picker or unlisted.
    public let visibleInPicker: Bool

    /// Used for sorting custom emoji in the picker.
    public let category: String?

    private enum CodingKeys: String, CodingKey {
        case shortcode
        case url
        case staticUrl = "static_url"
        case visibleInPicker = "visible_in_picker"
        case category
    }
}
