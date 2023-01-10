import Foundation

public class Application: Codable {
    public let name: String
    public let website: URL?
    
    public init(name: String, website: URL? = nil) {
        self.name = name
        self.website = website
    }
}
