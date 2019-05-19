//
//  Copyright (c) 2019 shinren.pan@gmail.com All rights reserved.
//

import Foundation

public extension NSObjectProtocol where Self: NSObject
{
    func removeChangeListener()
    {
        _changeListener.removeAllObjects()
    }
}

// MARK: -

public extension NSObjectProtocol where Self: NSObject
{
    func addChangeListener<T>(
        keyPath: KeyPath<Self, T>,
        callback: @escaping (_ changed: NSKeyValueObservedChange<T>) -> Void
    )
    {
        guard let key = keyPath._kvcKeyPathString else
        {
            return
        }

        let observer = observe(keyPath, options: [.old, .new])
        {
            callback($1)
        }

        _changeListener[key] = observer
    }
}

// MARK: -

public extension NSObjectProtocol where Self: NSObject
{
    static func LoadNib(named: String? = nil) -> Self
    {
        let result = Self()
        let named = named ?? "\(Self.self)"
        Bundle.main.loadNibNamed(named, owner: result, options: nil)
        return result
    }
}

// MARK: -

private extension NSObject
{
    var _changeListener: NSMutableDictionary
    {
        if let result = objc_getAssociatedObject(
            self,
            &AssociatedKey.NSObject.ChangeListener
        ) as? NSMutableDictionary
        {
            return result
        }

        let result = NSMutableDictionary()

        objc_setAssociatedObject(
            self,
            &AssociatedKey.NSObject.ChangeListener,
            result,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        return result
    }
}
