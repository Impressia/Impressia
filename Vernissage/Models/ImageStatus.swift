//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//
    
import Foundation
import UIKit
import MastodonSwift

public struct ImageStatus: Identifiable {
    public let id: String
    public let image: UIImage
    public let status: Status
}
