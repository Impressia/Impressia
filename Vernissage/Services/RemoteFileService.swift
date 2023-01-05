//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    

import Foundation

public class RemoteFileService {
    public static let shared = RemoteFileService()
    private init() { }
    
    public func fetchData(url: URL) async throws -> Data? {
        let urlRequest = URLRequest(url: url)
        
        // Fetching data.
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            return nil
        }
        
        return data
    }
}
