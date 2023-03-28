//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//
    
import Foundation

public struct AppMetadata: Codable {
    public let instructionsUrl: String
    public let serversUrl: String
    public let instances: [String]
    
    init() {
        self.instructionsUrl = "https://pixelfed.org/how-to-join"
        self.serversUrl = "https://pixelfed.org/servers"
        self.instances = [
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
            "https://faf.photos",
            "https://pix.vleij.com",
            "https://pixels.gsi.li",
            "https://eorzea.photos"
        ]
    }
}
