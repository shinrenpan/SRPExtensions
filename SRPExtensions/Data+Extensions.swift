//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import CommonCrypto

public enum AESError: Error
{
    case invalidKeyData, invalidKeyLength, failure
}

// MARK: -

public extension Data
{
    func aesEncrypt(key: String, iv: String? = nil) throws -> Data
    {
        return try __aesWith(operation: CCOperation(kCCEncrypt), key: key, iv: iv)
    }
}

// MARK: -

public extension Data
{
    func aesDecrypt(key: String, iv: String? = nil) throws -> Data
    {
        return try __aesWith(operation: CCOperation(kCCDecrypt), key: key, iv: iv)
    }
}

// MARK: -

private extension Data
{
    func __aesWith(operation: CCOperation, key: String, iv: String? = nil) throws -> Data
    {
        guard let keyData = key.data(using: .utf8) else
        {
            throw AESError.invalidKeyData
        }

        let keyLength = keyData.count
        let validKeyLengths = [kCCKeySizeAES128, kCCKeySizeAES192, kCCKeySizeAES256]

        guard validKeyLengths.contains(keyLength) else
        {
            throw AESError.invalidKeyLength
        }

        var ivBuffer: UnsafePointer<UInt8>?

        if
            let ivData: Data = iv?.data(using: .utf8),
            ivData.count > 0
        {
            ivBuffer = ivData.withUnsafeBytes
            {
                $0.load(as: UnsafePointer<UInt8>.self)
            }
        }

        let algorithm = CCAlgorithm(kCCAlgorithmAES)
        let options = CCOptions(kCCOptionPKCS7Padding)

        let keyBytes = keyData.withUnsafeBytes
        {
            $0.load(as: UnsafePointer<UInt8>.self)
        }

        let dataBytes = withUnsafeBytes
        {
            $0.load(as: UnsafePointer<UInt8>.self)
        }

        let dataLength = count
        var bufferData = Data(count: dataLength + kCCBlockSizeAES128)

        let bufferPointer = bufferData.withUnsafeMutableBytes
        {
            $0.load(as: UnsafeMutablePointer<UInt8>.self)
        }

        let bufferLength = size_t(bufferData.count)
        var bytesDecrypted = 0

        let cryptStatus: CCRNGStatus = CCCrypt(
            operation,
            algorithm,
            options,
            keyBytes,
            keyLength,
            ivBuffer,
            dataBytes,
            dataLength,
            bufferPointer,
            bufferLength,
            &bytesDecrypted
        )

        guard UInt32(cryptStatus) == UInt32(kCCSuccess) else
        {
            throw AESError.failure
        }

        bufferData.count = bytesDecrypted

        return bufferData
    }
}
