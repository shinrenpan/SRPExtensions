//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

// MARK: - Public

public extension UIImage
{
    static func CleanCacheImage(urlString: String? = nil)
    {
        let fileManager: FileManager = FileManager.default
        var deletePath = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent(AssociatedKey.UIImage.CachePath, isDirectory: true)

        if
            let urlString = urlString,
            let fileName = urlString.md5
        {
            deletePath.appendPathComponent(fileName)
        }

        try? fileManager.removeItem(at: deletePath)
    }
}

public extension UIImage
{
    final func sizeToFit(onView view: UIView?) -> UIImage?
    {
        guard let view = view else
        {
            return self
        }

        let width = size.width
        let height = size.height
        var scaleFactor: CGFloat

        if width > height
        {
            scaleFactor = view.frame.size.height / height
        }
        else
        {
            scaleFactor = view.frame.size.width / width
        }

        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: width * scaleFactor, height: height * scaleFactor),
            false,
            0.0
        )

        draw(in: CGRect(x: 0, y: 0, width: width * scaleFactor, height: height * scaleFactor))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
