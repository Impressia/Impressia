import Foundation

public struct ImageMetadata: Metadata {
    public let original: ImageInfo?
    public let small: ImageInfo?
    public let focus: Focus?

    private enum CodingKeys: String, CodingKey {
        case original
        case small
        case focus
    }
}
