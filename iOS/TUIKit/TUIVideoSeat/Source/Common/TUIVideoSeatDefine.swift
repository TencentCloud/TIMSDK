//
//  TUIVideoSeatDefine.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/13.
//

import Foundation

let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height

let kDeviceIsIphoneX: Bool = {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return false
    }
    let size = UIScreen.main.bounds.size
    let notchValue = Int(size.width / size.height * 100)
    if notchValue == 216 || notchValue == 46 {
        return true
    }
    return false
}()

let kDeviceSafeTopHeight: CGFloat = {
    if kDeviceIsIphoneX {
        return 44
    } else {
        return 20
    }
}()

let kDeviceSafeBottomHeight: CGFloat = {
    if kDeviceIsIphoneX {
        return 34
    } else {
        return 0
    }
}()
