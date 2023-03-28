//
//  https://mczachurski.dev
//  Copyright © 2022 Marcin Czachurski and the repository contributors.
//  Licensed under the Apache License 2.0.
//

import Foundation
import UIKit

public extension Dictionary<String, Any> {
    func getExifValue(_ key: String) -> String? {
        if let value = self[key] as? String {
            return value
        }
        
        if let dictionary = self[key] as? [String: Any], let value = dictionary[key] {
            return value as? String
        }
        
        return nil
    }
}

public extension Data {
    func getExifData() -> [String: Any]? {
        var imageInfo: [String: Any]? = nil
        
        guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil),
              let metadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil),
              let tags = CGImageMetadataCopyTags(metadata) else {
            return nil
        }
        
        imageInfo = self.readMetadataTagArr(tagArr: tags)
        return imageInfo
    }
    
    /// Reads the Arrays of tags and convert them into a dictionary of [String: Any].
    private func readMetadataTagArr(tagArr: CFArray) -> [String: Any]? {
        var result = [String: Any]()

        for (_, tag) in (tagArr as NSArray).enumerated() {
            let tagMetadata = tag as! CGImageMetadataTag
            if let cfName = CGImageMetadataTagCopyName(tagMetadata) {
                let name = String(cfName)
                result[name] = self.readMetadataTag(metadataTag: tagMetadata)
            }
        }
        return result
    }

    /// Convert CGImageMetadataTag to a dictionary of [String: Any].
    private func readMetadataTag(metadataTag: CGImageMetadataTag) -> [String: Any] {
        var result = [String: Any]()
        guard let cfName = CGImageMetadataTagCopyName(metadataTag) else { return result }
        let name = String(cfName)
        let value = CGImageMetadataTagCopyValue(metadataTag)
        
        /// checking the type of `value` object and then performing respective operation on `value`
        if CFGetTypeID(value) == CFStringGetTypeID() {
            let valueStr = String(value as! CFString)
            result[name] = valueStr
        } else if CFGetTypeID(value) == CFDictionaryGetTypeID() {
            let nsDict: NSDictionary = value as! CFDictionary
            result[name] = self.getDictionary(from: nsDict)
        } else if CFGetTypeID(value) == CFArrayGetTypeID() {
            let valueArr: NSArray = value as! CFArray
            for (_, item) in valueArr.enumerated() {
                let tagMetadata = item as! CGImageMetadataTag
                result[name] = self.readMetadataTag(metadataTag: tagMetadata)
            }
        } else {
            // when the data was of some other type
            let descriptionString: CFString = CFCopyDescription(value);
            let str = String(descriptionString)
            result[name] = str
        }
        return result
    }

        /// Converting CGImage Metadata dictionary to [String: Any]
    private func getDictionary(from nsDict: NSDictionary) -> [String: Any] {
        var subDictionary = [String: Any]()
        for (key, val) in nsDict {
            guard let key = key as? String else { continue }
            let tempDict: [String: Any] = [key: val]
            if JSONSerialization.isValidJSONObject(tempDict) {
                subDictionary[key] = val
            } else {
                let mData = val as! CGImageMetadataTag
                let tempDict: [String: Any] = [key: self.readMetadataTag(metadataTag: mData)]
                if JSONSerialization.isValidJSONObject(tempDict) {
                    subDictionary[key] = tempDict
                }
            }
        }
        return subDictionary
    }
}
