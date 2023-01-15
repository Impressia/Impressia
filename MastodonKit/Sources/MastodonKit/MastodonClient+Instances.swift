import Foundation

public extension MastodonClient {
    func readInstanceInformation() async throws -> Instance {
        let request = try Self.request(for: baseURL, target: Mastodon.Instances.instance)
        return try await downloadJson(Instance.self, request: request)
    }
}
