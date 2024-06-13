//
//  CGFloat+Extension.swift
//  Alamofire
//
//  Created by aby on 2022/12/26.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import UIKit

var kScreenWidth: CGFloat {
    UIScreen.main.bounds.width
}
var kScreenHeight: CGFloat {
    UIScreen.main.bounds.height
}

public let kDeviceIsiPhoneX : Bool = {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return false
    }
    let size = UIScreen.main.bounds.size
    let notchValue = Int(size.width/size.height*100)
    if notchValue == 216 || notchValue == 46 {
        return true
    }
    return false
}()

public let kDeviceSafeBottomHeight : CGFloat = {
    if kDeviceIsiPhoneX {
        return 34
    }
    else {
        return 0
    }
}()
private var width: CGFloat {
    return min(kScreenHeight, kScreenWidth)
}
private var height: CGFloat {
    return max(kScreenWidth, kScreenHeight)
}

extension CGFloat {
    
    /// Dimensions in 375 design drawings
    ///
    /// - Returns: Final result scaling result
    public func scale375(exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? self * 1.5 : self * (width / 375.00)
        }
        return self * (width / 375.00)
    }
    
    public func scale375Height(exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? self * 1.5 : self * (height / 812.00)
        }
        return self * (height / 812.00)
    }
    
    /// iPad proportion adaptation
    ///
    /// - Returns: Final Results
    public func fitPad() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? self * 1.5 : self
    }
}

extension Int {
    public func scale375(exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? CGFloat(self) * 1.5 : CGFloat(self) * (width / 375.00)
        }
        return CGFloat(self) * (width / 375.00)
    }
    
    public func scale375Height(exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? CGFloat(self) * 1.5 : CGFloat(self) * (height / 812.00)
        }
        return CGFloat(self) * (height / 812.00)
    }
    
    public func fitPad() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(self) * 1.5 : CGFloat(self)
    }
}
