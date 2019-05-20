//
//  Copyright (c) 2019年 shinren.pan@gmail.com All rights reserved.
//

import UIKit

public extension UIImageView
{
    final func imageFrom(
        urlString: String?,
        placeHolder: UIImage? = nil,
        autoFit: Bool = true,
        callback: (() -> Void)? = nil
    )
    {
        DispatchQueue.global().async
        { [weak self] in
            self?._downloadId = nil

            guard
                let urlString = urlString,
                let url = URL(string: urlString),
                let fileName = urlString.md5
            else
            {
                DispatchQueue.main.async
                {
                    self?.image = autoFit ? placeHolder?.sizeToFit(onView: self) : placeHolder
                    callback?()
                }

                return
            }

            let fileManager = FileManager.default

            let cacheFolder = fileManager.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first!.appendingPathComponent(AssociatedKey.UIImage.CachePath, isDirectory: true)

            // 每次都要建一次, 不然會有問題. Why?
            try? fileManager.createDirectory(
                at: cacheFolder,
                withIntermediateDirectories: true
            )

            let cacheFilePath = cacheFolder.appendingPathComponent(fileName)

            // 如果已經找到 Cache Image
            if let cacheImage = UIImage(contentsOfFile: cacheFilePath.path)
            {
                DispatchQueue.main.async
                {
                    self?.image = autoFit ? cacheImage.sizeToFit(onView: self) : cacheImage
                    callback?()
                }

                return
            }

            self?._downloadId = fileName

            DispatchQueue.main.async
            {
                self?.image = autoFit ? placeHolder?.sizeToFit(onView: self) : placeHolder
                callback?()
            }

            let configure = URLSessionConfiguration.ephemeral
            let session = URLSession(configuration: configure)

            session.dataTask(with: url)
            { data, response, _ in
                if
                    let data = data,
                    let image = UIImage(data: data)
                {
                    try? data.write(to: cacheFilePath)

                    if self?._downloadId == response?.url?.absoluteString.md5
                    {
                        DispatchQueue.main.async
                        {
                            self?.image = autoFit ? image.sizeToFit(onView: self) : image
                            callback?()
                        }
                    }
                }
            }.resume()

            session.finishTasksAndInvalidate()
        }
    }
}

private extension UIImageView
{
    var _downloadId: String?
    {
        get
        {
            return objc_getAssociatedObject(
                self,
                &AssociatedKey.UIImageView.DownloadId
            ) as? String
        }
        set
        {
            objc_setAssociatedObject(
                self,
                &AssociatedKey.UIImageView.DownloadId,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
