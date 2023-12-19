//
//  Constants.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

// 默认头像
let TUI_CALL_DEFAULT_AVATAR: String = "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png"

// MARK: 屏幕尺寸相关
let ScreenSize = UIScreen.main.bounds.size
let Screen_Width = UIScreen.main.bounds.size.width
let Screen_Height = UIScreen.main.bounds.size.height
let StatusBar_Height: CGFloat = {
    var statusBarHeight: CGFloat = 0
    if #available(iOS 13.0, *) {
        statusBarHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    } else {
        statusBarHeight = UIApplication.shared.statusBarFrame.height
    }
    return statusBarHeight
}()
let Bottom_SafeHeight = {var bottomSafeHeight: CGFloat = 0
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.windows.first
        bottomSafeHeight = window?.safeAreaInsets.bottom ?? 0
    }
    return bottomSafeHeight
}()

// MARK: FloatWindow UI Param

let kMicroAudioViewWidth = 88.scaleWidth()
let kMicroAudioViewHeight = 88.scaleWidth()
let kMicroVideoViewWidth = 110.scaleWidth()
let kMicroVideoViewHeight = 196.scaleHeight()
let kMicroGroupViewWidth = 88.scaleWidth()
let kMicroGroupViewHeight = 106.scaleWidth()

let kMicroAudioViewRect = CGRect(x: Screen_Width - kMicroAudioViewWidth, 
                                 y: 150.scaleHeight(),
                                 width: kMicroAudioViewWidth,
                                 height: kMicroAudioViewHeight)
let kMicroVideoViewRect = CGRect(x: Screen_Width - kMicroVideoViewWidth, 
                                 y: 150.scaleHeight(),
                                 width: kMicroVideoViewWidth,
                                 height: kMicroVideoViewHeight)
let kMicroGroupViewRect = CGRect(x: Screen_Width - kMicroGroupViewWidth,
                                 y: 150.scaleHeight(),
                                 width: kMicroGroupViewWidth,
                                 height: kMicroGroupViewHeight)

// MARK: UI Size Param
let kFloatWindowButtonSize = CGSize(width: 30, height: 30)
let kInviteUserButtonSize = CGSize(width: 30, height: 30)

// MARK: TUICore & IM
let TMoreCell_Image_Size = CGSize(width: 65, height: 65)

let TUI_CALLING_BELL_KEY = "CallingBell"
let MAX_USER = 9
let ENABLE_MUTEMODE_USERDEFAULT = "ENABLE_MUTEMODE_USERDEFAULT"
let TUI_CALLKIT_SIGNALING_MAX_TIME : Int32 = 30

let kControlBtnSize = CGSize(width: 100.scaleWidth(), height: 94.scaleWidth())
let kBtnLargeSize = CGSize(width: 64.scaleWidth(), height: 64.scaleWidth())
let kBtnSmallSize = CGSize(width: 60.scaleWidth(), height: 60.scaleWidth())

class Constants {
    static let EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER = "eventShowTUICallKitViewController"
}
