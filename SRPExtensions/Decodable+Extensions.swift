//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import Foundation

public extension Decodable
{
    static func FromSandbox(named: String, aesKey: String? = nil, aesIV: String? = nil) -> Self?
    {
        guard let path = Self.__SavePath(for: named) else
        {
            return nil
        }
        
        guard let data = try? Data(contentsOf: path) else
        {
            return nil
        }
        
        var temp: Data? = data
        
        if let aesKey = aesKey
        {
            temp = try? data.aesDecrypt(key: aesKey, iv: aesIV)
        }
        
        guard let decodeData = temp else
        {
            return nil
        }
        
        return try? JSONDecoder().decode(self, from: decodeData)
    }
}

// MARK: -

public enum HTTPError: Error
{
    case invalidURL, connectFailure, emptyResponseBody
}

// MARK: -

public enum HTTPMethod: String
{
    case GET, POST, PUT, DELETE
}

// MARK: -

public extension Decodable
{
    static func RESTFul(
        httpMethod: HTTPMethod,
        urlString: String,
        configure: URLSessionConfiguration = URLSessionConfiguration.default,
        params: [String: Any]? = nil,
        aesKey: String? = nil,
        aesIV: String? = nil,
        callback: @escaping (_ result: Result<Self, Error>) -> Void
    )
    {
        guard let url = Self.__HTTPURL(
            httpMethod: httpMethod,
            urlString: urlString,
            params: params
        ) else
        {
            return callback(.failure(HTTPError.invalidURL))
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = Self.__HTTPBody(httpMethod: httpMethod, params: params)

        let session = URLSession(configuration: configure)
        let task = session.dataTask(with: request)
        { data, _, error in
            var result: Result<Self, Error> = .failure(HTTPError.connectFailure)

            defer
            {
                DispatchQueue.main.async
                {
                    callback(result)
                }
            }

            if let error = error
            {
                return result = .failure(error)
            }

            guard let data = data else
            {
                return result = .failure(HTTPError.emptyResponseBody)
            }

            var data_ = data

            if let aesKey = aesKey
            {
                do
                {
                    data_ = try data_.aesDecrypt(key: aesKey, iv: aesIV)
                }
                catch let e
                {
                    return result = .failure(e)
                }
            }

            let decoder = JSONDecoder()

            do
            {
                result = .success(try decoder.decode(Self.self, from: data_))
            }
            catch let e
            {
                result = .failure(e)
            }
        }

        task.resume()
        session.finishTasksAndInvalidate()
    }
}

// MARK: -

private extension Decodable
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

// MARK: -

private extension Decodable
{
    static func __HTTPURL(httpMethod: HTTPMethod, urlString: String, params: [String: Any]?) -> URL?
    {
        switch httpMethod
        {
            case .GET:
                return Self.__URLComponent(urlString: urlString, params: params)?.url
            default:
                return URL(string: urlString)
        }
    }
}

// MARK: -

private extension Decodable
{
    static func __HTTPBody(httpMethod: HTTPMethod, params: [String: Any]?) -> Data?
    {
        guard let params = params else
        {
            return nil
        }

        switch httpMethod
        {
            case .GET:
                return nil
            default:
                return try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        }
    }
}

// MARK: -

private extension Decodable
{
    static func __URLComponent(urlString: String, params: [String: Any]?) -> URLComponents?
    {
        guard var result = URLComponents(string: urlString) else
        {
            return nil
        }

        guard let params = params else
        {
            return result
        }

        var queryItems: [URLQueryItem] = []

        for (key, value) in params
        {
            // 如果參數為 { "Key": [1, 2, 3] }
            // query path = key=1&key=2&key=3
            if let array = value as? Array<Any>
            {
                let items = array.map
                {
                    URLQueryItem(name: key, value: String(describing: $0))
                }

                queryItems.append(contentsOf: items)
            }
            else
            {
                let item = URLQueryItem(name: key, value: String(describing: value))
                queryItems.append(item)
            }
        }

        if result.queryItems == nil
        {
            result.queryItems = queryItems
        }
        else
        {
            result.queryItems?.append(contentsOf: queryItems)
        }

        return result
    }
}
