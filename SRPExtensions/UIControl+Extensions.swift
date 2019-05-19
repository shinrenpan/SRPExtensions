//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import UIKit

public extension NSObjectProtocol where Self: UIControl
{
    func addEventListener(
        event: UIControl.Event,
        callback: @escaping (_ sender: Self) -> Void
    )
    {
        let target = _ActionTarget<Self>()
        target.callback = callback
        target.sender = self
        _eventListener["\(event.rawValue)"] = target
        addTarget(target, action: #selector(target.action), for: event)
    }
}

// MARK: -

private extension UIControl
{
    var _eventListener: NSMutableDictionary
    {
        if let result = objc_getAssociatedObject(
            self,
            &AssociatedKey.UIControl.EventListener
        ) as? NSMutableDictionary
        {
            return result
        }

        let result = NSMutableDictionary()

        objc_setAssociatedObject(
            self,
            &AssociatedKey.UIControl.EventListener,
            result,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        return result
    }
}

// MARK: -

private final class _ActionTarget<T: UIControl>
{
    weak var sender: T?
    var callback: ((T) -> Void)?

    @objc final func action()
    {
        guard let sender = sender else
        {
            return
        }

        guard let callback = callback else
        {
            return
        }

        callback(sender)
    }
}
