//
//  LayoutDefine.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

public let ScreenWidth = UIScreen.main.bounds.width
public let ScreenHeight = UIScreen.main.bounds.height

public let kDeviceIsIphoneX : Bool = {
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

public let kDeviceSafeTopHeight : CGFloat = {
    if kDeviceIsIphoneX {
        return 44
    }
    else {
        return 20
    }
}()

public let kDeviceSafeBottomHeight : CGFloat = {
    if kDeviceIsIphoneX {
        return 34
    }
    else {
        return 0
    }
}()

public func convertPixel(w:CGFloat) -> CGFloat {
    return w/375.0*ScreenWidth
}

public func convertPixel(h:CGFloat) -> CGFloat {
    return h/812.0*ScreenHeight
}

