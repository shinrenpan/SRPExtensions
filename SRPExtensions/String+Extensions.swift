//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import CommonCrypto
import Foundation

public extension String
{
    var base64: String?
    {
        return data(using: .utf8)?.base64EncodedString()
    }
}

// MARK: -

public extension String
{
    var md5: String?
    {
        let data = Data(utf8)
        let hash = data.withUnsafeBytes
        { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: -

public extension String
{
    func between(start: String, end: String) -> [String]?
    {
        if count <= (start.count + end.count)
        {
            return nil
        }

        let pattern = "(?<=\(start))(.*)(?=\(end))"
        var regular: NSRegularExpression

        do
        {
            regular = try NSRegularExpression(pattern: pattern, options: [])
        }
        catch
        {
            return nil
        }

        let range = NSRange(location: 0, length: count)
        let matches = regular.matches(in: self, options: [], range: range)

        var result = matches.map
        {
            (self as NSString).substring(with: $0.range)
        }

        result = result.filter
        {
            $0.count > 0
        }

        return result.isEmpty ? nil : result
    }
}
