import Foundation

public extension MastodonClient {
    func readInstanceInformation() async throws -> Instance {
        let request = try Self.request(for: baseURL, target: Mastodon.Instances.instance )
        let (data, _) = try await urlSession.data(for: request)

        return try JSONDecoder().decode(Instance.self, from: data)
    }
}
