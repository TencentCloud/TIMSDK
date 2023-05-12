//
//  Constants.swift
//
//  Created by vincepzhang on 2022/12/30.
//

// 默认头像
let TUI_CALL_DEFAULT_AVATAR: String = "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png"

// TODO: 引用TUICore中的宏定义出错，现将出错的宏定义在此
let ScreenSize = UIScreen.main.bounds.size
let Screen_Width = UIScreen.main.bounds.size.width
let Screen_Height = UIScreen.main.bounds.size.height
let Is_Iphone = (UI_USER_INTERFACE_IDIOM() == .phone)
let Is_IPhoneX = (Screen_Width >= 375.0 && Screen_Height >= 812.0 && Is_Iphone)
let StatusBar_Height = Is_IPhoneX ? 44.0 : 20.0
let Bottom_SafeHeight = Is_IPhoneX ? 34.0 : 0

// MARK: FloatWindow Param
public let kMicroAudioViewWidth = 80.0
public let kMicroAudioViewHeight = 80.0
public let kMicroVideoViewWidth = 100.0
public let kMicroVideoViewHeight = (100.0 * 16) / 9.0
public let kMicroAudioViewRect = CGRectMake(Screen_Width - kMicroAudioViewWidth, 150, kMicroAudioViewWidth, kMicroAudioViewHeight)
public let kMicroVideoViewRect = CGRectMake(Screen_Width - kMicroVideoViewWidth, 150, kMicroVideoViewWidth, kMicroVideoViewHeight)
public let kMicroVideoDisAvailableViewRect = CGRectMake(Screen_Width - kMicroVideoViewWidth, 150, kMicroVideoViewWidth, kMicroVideoViewHeight - 10)

let TUI_CALLING_BELL_KEY = "CallingBell"

let MAX_USER = 9

let ENABLE_MUTEMODE_USERDEFAULT = "ENABLE_MUTEMODE_USERDEFAULT"
