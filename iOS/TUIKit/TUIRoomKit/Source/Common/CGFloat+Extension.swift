//
//  CGFloat+Extension.swift
//  Alamofire
//
//  Created by aby on 2022/12/26.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import UIKit

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

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

private let width = UIScreen.main.bounds.width
private let height = UIScreen.main.bounds.height

extension CGFloat {
    
    /// 375设计图中的尺寸
    ///
    /// - Returns: 最终结果缩放结果
    public func scale375(exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? self * 1.5 : self * (width / 375.00)
        }
        return self * (width / 375.00)
    }
    
    public func scale375Height(exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // TODO 此处的pad高度系数需要调研
            return exceptPad ? self * 1.5 : self * (height / 812.00)
        }
        return self * (height / 812.00)
    }
    
    /// iPad比例适配
    ///
    /// - Returns: 最终结果
    public func fitPad() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? self * 1.5 : self
    }
}

extension Int {
    /// 375设计图中的尺寸
    ///
    /// - Returns: 最终结果
    public func scale375(exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? CGFloat(self) * 1.5 : CGFloat(self) * (width / 375.00)
        }
        return CGFloat(self) * (width / 375.00)
    }
    
    public func scale375Height(exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // TODO 此处的pad高度系数需要调研
            return exceptPad ? CGFloat(self) * 1.5 : CGFloat(self) * (height / 812.00)
        }
        return CGFloat(self) * (height / 812.00)
    }
    
    /// iPad比例适配
    ///
    /// - Returns: 最终结果
    public func fitPad() -> CGFloat {
        return UIDevice.current.userInterfaceIdiom == .pad ? CGFloat(self) * 1.5 : CGFloat(self)
    }
}
