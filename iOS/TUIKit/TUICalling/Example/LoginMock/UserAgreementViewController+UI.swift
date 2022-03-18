//
//  UserAgreementViewController+UI.swift
//  TXLiteAVDemo
//
//  Created by lijie on 2020/6/23.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import SnapKit
import WebKit
import TXAppBasic

extension UserAgreementViewController {
    func setupUI() {
        self.title = LoginLocalize(key:"V2.Live.LinkMicNew.termsandconditions")
        
        let htmlPath = Bundle.main.path(forResource: "UserProtocol", ofType: "html")
        var htmlContent = ""
        do {
            htmlContent = try String(contentsOfFile: htmlPath ?? "")
        } catch {
        }
        
        let lineView1 = UIView()
        lineView1.backgroundColor = UIColor.gray
        view.addSubview(lineView1)
        lineView1.snp.remakeConstraints { (make) in
            make.width.equalTo(view)
            make.height.equalTo(0.5)
            make.leading.equalTo(0)
            make.bottom.equalTo(view).offset(-50 - bottomPadding)
        }
        
        let lineView2 = UIView()
        lineView2.backgroundColor = UIColor.gray
        view.addSubview(lineView2)
        lineView2.snp.remakeConstraints { (make) in
            make.width.equalTo(0.5)
            make.height.equalTo(49)
            make.leading.equalTo(view.snp.trailing).dividedBy(2)
            make.top.equalTo(lineView1.snp.bottom)
        }
        
        let agreeBtn = UIButton()
        agreeBtn.setTitle(LoginLocalize(key:"V2.Live.LinkMicNew.agree"), for: .normal)
        agreeBtn.setTitleColor(UIColor.init(0x0062E3), for: .normal)
        view.addSubview(agreeBtn)
        agreeBtn.snp.remakeConstraints { (make) in
            make.width.equalTo(view).dividedBy(2)
            make.height.equalTo(49)
            make.leading.equalTo(0)
            make.top.equalTo(lineView1.snp.bottom)
        }
        agreeBtn.addTarget(self, action: #selector(agreeBtnClick), for: .touchUpInside)
        
        
        let unAgreeBtn = UIButton()
        unAgreeBtn.setTitle(LoginLocalize(key:"V2.Live.LinkMicNew.disagree"), for: .normal)
        unAgreeBtn.setTitleColor(UIColor.init(0x0062E3), for: .normal)
        view.addSubview(unAgreeBtn)
        unAgreeBtn.snp.remakeConstraints { (make) in
            make.width.equalTo(view).dividedBy(2)
            make.height.equalTo(49)
            make.leading.equalTo(view.snp.trailing).dividedBy(2)
            make.top.equalTo(lineView1.snp.bottom)
        }
        unAgreeBtn.addTarget(self, action: #selector(unAgreeBtnClick), for: .touchUpInside)
        
        
        let webView = WKWebView()
        webView.loadHTMLString(htmlContent, baseURL: Bundle.main.bundleURL)
        view.addSubview(webView)
        webView.snp.remakeConstraints { (make) in
            make.top.equalTo(topPadding)
            make.bottom.equalTo(lineView1.snp.top)
            make.leading.equalTo(0)
            make.width.equalTo(view)
        }
    }
    
    @objc func agreeBtnClick() {
        agree()
    }
    
    @objc func unAgreeBtnClick() {
        unAgree()
    }
    
    func agree() {
        UserDefaults.standard.set(true, forKey: UserAgreementViewController.UserAgreeKey)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: completion)
    }
    
    func unAgree() {
        UserDefaults.standard.set(false, forKey: UserAgreementViewController.UserAgreeKey)
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: completion)
    }
    
}
