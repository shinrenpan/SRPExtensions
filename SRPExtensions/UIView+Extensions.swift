//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import UIKit

public extension NSObjectProtocol where Self: UIView
{
    static func FromNib(named: String? = nil, index: Int = 0) -> Self
    {
        let named = named ?? "\(Self.self)"
        let nib = UINib(nibName: named, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[index] as! Self
    }
}

public extension UIView
{
    func snapshot() -> UIImage?
    {
        if let scrollView = self as? UIScrollView
        {
            let contenOffset = scrollView.contentOffset
            let frame = scrollView.frame
            let contentSize = scrollView.contentSize
            UIGraphicsBeginImageContext(scrollView.contentSize)

            guard let context = UIGraphicsGetCurrentContext() else
            {
                return nil
            }

            scrollView.contentOffset = .zero

            scrollView.frame = CGRect(
                x: 0,
                y: 0,
                width: contentSize.width,
                height: contentSize.height
            )

            scrollView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            scrollView.contentOffset = contenOffset
            scrollView.frame = frame
            return image
        }

        UIGraphicsBeginImageContext(bounds.size)

        guard let context = UIGraphicsGetCurrentContext() else
        {
            return nil
        }

        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
