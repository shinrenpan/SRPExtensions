//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import Foundation

public extension Encodable
{
    @discardableResult
    func saveToSandbox(named: String, aesKey: String? = nil, aesIV: String? = nil) -> Bool
    {
        guard let path = Self.__SavePath(for: named) else
        {
            return false
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(self) else
        {
            return false
        }

        var temp: Data? = data

        if let aesKey = aesKey
        {
            temp = try? data.aesEncrypt(key: aesKey, iv: aesIV)
        }

        guard let saveData = temp else
        {
            return false
        }

        do
        {
            try saveData.write(to: path)
            return true
        }
        catch
        {
            return false
        }
    }
}

// MARK: -

public extension Encodable
{
    @discardableResult
    static func DeleteInSandbox(named: String) -> Bool
    {
        guard let path = Self.__SavePath(for: named) else
        {
            return false
        }

        do
        {
            try FileManager.default.removeItem(at: path)
            return true
        }
        catch
        {
            return false
        }
    }
}

// MARK: -

private extension Encodable
{
    static func __SavePath(for fileName: String) -> URL?
    {
        let fileManager: FileManager = FileManager.default

        guard let cachesFolder = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first else
        {
            return nil
        }

        let folder = cachesFolder.appendingPathComponent(AssociatedKey.Codable.DataPath, isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        // 把 User 的副檔名移除, 再加回 .json
        return folder.appendingPathComponent(fileName)
            .deletingPathExtension()
            .appendingPathExtension("json")
    }
}
