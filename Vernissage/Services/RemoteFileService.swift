//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import PixelfedKit
import Nuke

public class RemoteFileService {
    public static let shared = RemoteFileService()
    private init() { }
    
    public func fetchData(url: URL) async throws -> Data? {
        let request = ImageRequest(
            url: url,
            priority: .high
        )
        
        let (data, response) = try await ImagePipeline.shared.data(for: request)
        
        guard let response else {
            return data
        }
        
        guard (response as? HTTPURLResponse)?.status?.responseType == .success else {
            throw NetworkError.notSuccessResponse(response)
        }
        
        return data
    }
}
