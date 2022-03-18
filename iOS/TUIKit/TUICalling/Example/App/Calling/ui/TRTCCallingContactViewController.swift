//
//  TRTCCallingContactViewController.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/8/6.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import TUICalling
import UIKit

public class TRTCCallingContactViewController: UIViewController, TUICallingListerner {
    var selectedFinished: (([V2TIMUserFullInfo])->Void)? = nil
    var callingVC = UIViewController()
    @objc var callType: CallType = .audio
    
    lazy var callingContactView: TRTCCallingContactView = {
        let callingContactView = TRTCCallingContactView(frame: .zero, type: .call) { [weak self] users in
            guard let `self` = self else {return}
            var userIds: [String] = []
            for V2TIMUserFullInfo in users {
                userIds.append(V2TIMUserFullInfo.userID)
            }
            self.showCallVC(users: userIds)
        }
        
        return callingContactView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        TUICalling.shareInstance().setCallingListener(listener: self)
        TUICalling.shareInstance().enableCustomViewRoute(enable: true);
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "calling_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backBtn)
        item.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = item
        
        setupUI()
    }
    
    @objc func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    deinit {
        debugPrint("deinit \(self)")
        TUICalling.shareInstance().enableCustomViewRoute(enable: false);
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - TUICallingListerner
    
    public func shouldShowOnCallView() -> Bool {
        return true;
    }
    
    public func callStart(userIDs: [String], type: TUICallingType, role: TUICallingRole, viewController: UIViewController?) {
        
        if let vc = viewController {
            callingVC = vc;
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    public func callEnd(userIDs: [String], type: TUICallingType, role: TUICallingRole, totalTime: Float) {
        callingVC.dismiss(animated: true) {
        }
    }
    
    public func onCallEvent(event: TUICallingEvent, type: TUICallingType, role: TUICallingRole, message: String) {
    }
}

extension TRTCCallingContactViewController {
    
    func setupUI() {
        view.addSubview(callingContactView)
        
        callingContactView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.topMargin.equalTo(view)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func showCallVC(users: [String]) {
        var type: TUICallingType = .video
        if callType == .audio {
            type = .audio
        }
        TUICalling.shareInstance().call(userIDs: users, type: type)
    }
}
