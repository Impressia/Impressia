//
//  https://mczachurski.dev
//  Copyright © 2023 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

public class PhotoUrl: ObservableObject, Identifiable {
    public var id: String
    @Published public var url: URL?
    @Published public var blurhash: String?
    
    init(id: String) {
        self.id = id
    }
}
