//
//  TUIRoomViewController.swift
//  TUIRoom
//
//  Created by WesleyLei on 2021/12/16.
//  Copyright © 2021 Tencent. All rights reserved.
//

import SnapKit
import UIKit
import TUIRoomEngine
import TUICore

protocol RoomEntranceViewModelFactory {
    func makeRootView(isCreateRoom: Bool) -> UIView
}

class RoomEntranceViewController: UIViewController {
    
    let backButton: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_back_white", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        button.setTitleColor(UIColor(0xD1D9EC), for: .normal)
        return button
    }()
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    let rootView: UIView
    init(roomMainViewModelFactory: RoomEntranceViewModelFactory, isCreateRoom: Bool) {
        rootView = roomMainViewModelFactory.makeRootView(isCreateRoom: isCreateRoom)
        super.init(nibName: nil, bundle: nil)
        backButton.addTarget(self, action: #selector(backButtonClick(sender:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        UIApplication.shared.isIdleTimerDisabled = false
        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
    }
    
    @objc
    func backButtonClick(sender: UIButton) {
        RoomRouter.shared.pop()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
