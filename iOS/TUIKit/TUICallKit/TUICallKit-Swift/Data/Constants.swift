//
//  Constants.swift
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
let kMicroAudioViewWidth = 80.0
let kMicroAudioViewHeight = 80.0
let kMicroVideoViewWidth = 100.0
let kMicroVideoViewHeight = (100.0 * 16) / 9.0
let kMicroAudioViewRect = CGRect(x: Screen_Width - kMicroAudioViewWidth, y: 150, width: kMicroAudioViewWidth, height: kMicroAudioViewHeight)
let kMicroVideoViewRect = CGRect(x: Screen_Width - kMicroVideoViewWidth, y: 150, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight)
let kMicroVideoDisAvailableViewRect = CGRect(x: Screen_Width - kMicroVideoViewWidth,
                                             y: 150,
                                             width: kMicroVideoViewWidth,
                                             height: kMicroVideoViewHeight - 10)

// MARK: UI Size Param
let kFloatWindowButtonSize = CGSize(width: 30, height: 30)
let kInviteUserButtonSize = CGSize(width: 30, height: 30)

// MARK: TUICore & IM
let TMoreCell_Image_Size = CGSize(width: 65, height: 65)

let TUI_CALLING_BELL_KEY = "CallingBell"
let MAX_USER = 9
let ENABLE_MUTEMODE_USERDEFAULT = "ENABLE_MUTEMODE_USERDEFAULT"
let TUI_CALLKIT_SIGNALING_MAX_TIME : Int32 = 30

let kControlBtnSize = CGSize(width: 100, height: 92)
let kBtnLargeSize = CGSize(width: 64, height: 64)
let kBtnSmallSize = CGSize(width: 52, height: 52)

class Constants {
    static let EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER = "eventShowTUICallKitViewController"
}
