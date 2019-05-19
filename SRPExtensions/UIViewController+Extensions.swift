//
//  Copyright (c) 2018年 shinren.pan@gmail.com All rights reserved.
//

import UIKit

public extension NSObjectProtocol where Self: UIViewController
{
    static func FromStoryboard(named: String? = nil, Id: String? = nil) -> Self
    {
        let named = named ?? "\(Self.self)"
        let Id = Id ?? "\(Self.self)"
        let storyboard = UIStoryboard(name: named, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: Id) as! Self
    }
}
