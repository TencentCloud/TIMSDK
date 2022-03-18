//
//  UserAgreementViewController.swift
//  TXLiteAVDemo
//
//  Created by lijie on 2020/6/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit

class UserAgreementViewController: UIViewController {
    static let UserAgreeKey = "UserAgreeKey"  // 用户协议，登录或注册后第一次弹出
    
    typealias Completion = () -> Void
    var completion: Completion? = nil
    
    var topPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow!.safeAreaInsets.top
        }
        return 0
    }()
    
    var bottomPadding: CGFloat = {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow!.safeAreaInsets.top
        }
        return 0
    }()
    
    static func isAgree() -> Bool {
        if let isAgree = UserDefaults.standard.object(forKey: UserAgreeKey) as? Bool {
            return isAgree
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
