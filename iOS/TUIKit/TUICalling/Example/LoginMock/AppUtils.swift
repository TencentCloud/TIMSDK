//
//  appUtil.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/24/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//
// 用于TRTC_SceneDemo

import UIKit
import ImSDK_Plus

class AppUtils: NSObject {
    @objc public static let shared = AppUtils()
    private override init() {}
    
    var deviceToken: Data? = nil
    
    @objc var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    @objc var curUserId: String {
        get {
#if NOT_LOGIN
            return ""
#else
            return V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
#endif
        }
    }
    
    // MARK: - UI
    @objc func showMainController() {
        appDelegate.showMainViewController()
    }
    
    @objc func alertUserTips(_ vc: UIViewController) {
        // 提醒用户不要用Demo App来做违法的事情
        // 外发代码不需要提示
    }
}
