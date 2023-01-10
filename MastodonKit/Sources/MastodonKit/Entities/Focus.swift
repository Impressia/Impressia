import Foundation

public struct Focus: Codable {
    public let x: Int
    public let y: Int

    private enum CodingKeys: String, CodingKey {
        case x
        case y
    }
}
