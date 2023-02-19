//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the MIT License.
//

import Foundation

struct MultipartFormData {
    private let boundary: String
    private var httpBody = NSMutableData()

    private let separator: String = "\r\n"

    init(boundary: String) {
        self.boundary = boundary
    }

    func addTextField(named name: String, value: String) {
        httpBody.append("--\(boundary)\(separator)")
        httpBody.append(disposition(name) + separator)
        httpBody.append("Content-Type: text/plain; charset=UTF-8" + separator + separator)
        httpBody.append(value)
        httpBody.append(separator)
    }

    func addDataField(named name: String, fileName: String, data: Data, mimeType: String) {
        httpBody.append("--\(boundary)\(separator)")
        httpBody.append(disposition(name) + "; filename=\"\(fileName)\"" + separator)
        httpBody.append("Content-Type: \(mimeType)" + separator + separator)
        httpBody.append(data)
        httpBody.append(separator)
    }
    
    private func disposition(_ name: String) -> String {
        "Content-Disposition: form-data; name=\"\(name)\""
    }
        
    func build() -> Data {
        httpBody.append("--\(boundary)\(separator)")
        return httpBody as Data
    }
}
