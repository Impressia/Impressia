//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import MastodonKit

public class InstanceService {
    public static let shared = InstanceService()
    private init() { }
    
    func instances(urls: [String]) async -> [Instance] {
        var instances: [Instance] = []
        
        await withTaskGroup(of: Instance?.self) { group in
            for url in urls {
                group.addTask {
                    do {
                        if let baseUrl = URL(string: url) {
                            let client = MastodonClient(baseURL: baseUrl)
                            return try await client.readInstanceInformation()
                        }
                        
                        return nil
                    } catch {
                        ErrorService.shared.handle(error, message: "Cannot download instance information: \(url.string)")
                        return nil
                    }
                }
            }
            
            for await instance in group {
                if let instance {
                    instances.append(instance)
                }
            }
        }
        
        return instances
    }
}
