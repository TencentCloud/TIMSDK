//
//  TRTCLoginViewController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import Toast_Swift
import WebKit
import ImSDK_Plus

class TRTCLoginViewController: UIViewController {
    
    let loading = UIActivityIndicatorView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(loading)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .white
        ToastManager.shared.position = .center
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
        
        /// auto login
        if ProfileManager.shared.autoLogin(success: {
            self.loginIM { [weak self] (success) in
                guard let `self` = self else { return }
                self.loading.stopAnimating()
                if success {
                    self.loginSucc()
                }
            }
        }, failed: { [weak self] (err) in
            guard let self = self else {return}
            self.loading.stopAnimating()
            self.view.makeToast(err)
        }) {
            loading.startAnimating()
            if let rootView = view as? TRTCLoginRootView {
                rootView.phoneNumTextField.text = ProfileManager.shared.curUserModel?.phone ?? ""
            }
        }
    }
    
    
    func login(phone: String, code: String) {
        loading.startAnimating()
        ProfileManager.shared.login(phone: phone, code: code) { [weak self] in
            guard let `self` = self else { return }
            self.loading.stopAnimating()
            self.loginIM { [weak self] (success) in
                guard let `self` = self else { return }
                if success {
                    self.loginSucc()
                }
            }
        }
    }
    
    func loginIM(complete: @escaping (_ success: Bool)->Void) {
        guard let userID = ProfileManager.shared.curUserID() else { return }
        let userSig = ProfileManager.shared.curUserSig()
        V2TIMManager.sharedInstance()
        if V2TIMManager.sharedInstance()?.getLoginUser() != userID {
            ProfileManager.shared.IMLogin(userSig: userSig) {
                debugPrint("IM login success.")
                complete(true)
            } failed: { [weak self] (error) in
                guard let `self` = self else { return }
                self.view.makeToast(LoginLocalize(key: "App.PortalViewController.loginimfailed"))
                complete(false)
            }
        }
    }
    
    func loginSucc() {
        if ProfileManager.shared.curUserModel?.name.count == 0 {
            showRegisterVC()
        } else {
            self.view.makeToast(LoginLocalize(key:"V2.Live.LinkMicNew.loginsuccess"))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppUtils.shared.showMainController()
            }
        }
    }
    
    func showRegisterVC() {
        let vc = TRTCRegisterViewController.init()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func loadView() {
        super.loadView()
        let rootView = TRTCLoginRootView()
        rootView.rootVC = self
        view = rootView
    }
}

extension String {
    static let verifySuccessStr = "verifySuccess"
    static let verifyCancelStr = "verifyCancel"
    static let verifyErrorStr = "verifyError"
}
