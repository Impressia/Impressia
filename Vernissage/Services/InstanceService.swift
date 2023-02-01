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
    
    public let pixelfedInstances: [String] = [
        "https://pixelfed.de",
        "https://pixelfed.social",
        "https://pxlmo.com",
        "https://metapixl.com",
        "https://pixey.org",
        "https://pixel.tchncs.de",
        "https://pixelfed.tokyo",
        "https://pixelfed.fr",
        "https://pixelfed.nz",
        "https://pixelfed.au",
        "https://pixelfed.eus",
        "https://pixelfed.bachgau.social",
        "https://pixelfed.es",
        "https://pixelfed.cz",
        "https://pixelfed.automat.click",
        "https://gram.social",
        "https://nixorigin.one",
        "https://miniature.photography",
        "https://fedifilm.art",
        "https://fedipix.de",
        "https://pixel.jabbxi.de",
        "https://nodegray.com",
        "https://socialpixels.xyz",
        "https://pixel.mamutut.space",
        "https://pixelfed.fioverse.zone",
        "https://pixel.artemai.art",
        "https://pix.anduin.net",
        "https://jauntypix.net",
        "https://faf.photos",
        "https://pix.vleij.com",
        "https://pixels.gsi.li",
        "https://eorzea.photos"
    ]
    
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
