//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import UIKit

internal struct AssociatedKey {}

// MARK: -

internal extension AssociatedKey
{
    struct NSObject
    {
        static var ChangeListener = "ChangeListener"
    }
}

// MARK: -

internal extension AssociatedKey
{
    struct UIControl
    {
        static var EventListener = "EventListener"
    }
}

// MARK: -

internal extension AssociatedKey
{
    struct UIImage
    {
        static var CachePath = "SRPExtensions/ImageCache"
    }
}

// MARK: -

internal extension AssociatedKey
{
    struct Codable
    {
        static var DataPath = "SRPExtensions/Data"
    }
}

// MARK: -

internal extension AssociatedKey
{
    struct UIImageView
    {
        static var ImageDataTask = "ImageDataTask"
    }
}
