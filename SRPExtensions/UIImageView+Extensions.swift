//
//  Copyright (c) 2019年 shinren.pan@gmail.com All rights reserved.
//

import UIKit

public extension UIImageView
{
    final func imageFrom(
        urlString: String?,
        placeHolder: UIImage? = nil,
        autoFit: Bool = true
    )
    {
        self._imageDataTask?.cancel()
        self._imageDataTask = nil

        DispatchQueue.global().async
        { [weak self] in

            guard let urlString = urlString else
            {
                self?.__setImage(placeHolder, autoFit: autoFit)
                return
            }

            guard let url = URL(string: urlString) else
            {
                self?.__setImage(placeHolder, autoFit: autoFit)
                return
            }
            
            guard let fileName = urlString.md5 else
            {
                self?.__setImage(placeHolder, autoFit: autoFit)
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
                self?.__setImage(cacheImage, autoFit: autoFit)
                return
            }

            DispatchQueue.main.async
            {
                self?.__setImage(placeHolder, autoFit: autoFit)
            }

            self?._imageDataTask = URLSession.shared.dataTask(with: url)
            { (data, _ , error) in
                if let data = data, let image = UIImage(data: data)
                {
                    try? data.write(to: cacheFilePath)
                    self?.__setImage(image, autoFit: autoFit)
                }
            }

            self?._imageDataTask?.resume()
        }
    }
}

private extension UIImageView
{
    var _imageDataTask: URLSessionDataTask?
    {
        get
        {
            return objc_getAssociatedObject(
                self,
                &AssociatedKey.UIImageView.ImageDataTask
            ) as? URLSessionDataTask
        }
        set
        {
            objc_setAssociatedObject(
                self,
                &AssociatedKey.UIImageView.ImageDataTask,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    final func __setImage(_ image: UIImage?, autoFit: Bool)
    {
        DispatchQueue.main.async
        {
            self.image = autoFit ? image?.sizeToFit(onView: self) : image
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}
