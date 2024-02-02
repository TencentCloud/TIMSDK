//
//  CallKitViewController.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import UIKit
import TUICore

class CallKitViewController: UIViewController, SingleCallViewDelegate {
    
    let callEventObserver = Observer()
    var isStatusBarHidden = false
    
    deinit {
        TUICallState.instance.event.removeObserver(callEventObserver)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if TUICallState.instance.scene.value == .single {
            let callView: SingleCallView? = SingleCallView(frame: CGRect.zero)
            callView?.delegate = self
            view.addSubview(callView ?? UIView())
        } else if TUICallState.instance.scene.value == .group {
            let groupCallView = GroupCallView()
            view.addSubview(groupCallView)
        }
        
        registerObserver()
    }
    
    func registerObserver() {
        TUICallState.instance.event.addObserver(callEventObserver) { newValue, _ in
            if newValue.eventType == .ERROR {
                guard let errorCode = newValue.param[EVENT_KEY_CODE] as? Int32 else { return }
                guard let errorMessage = newValue.param[EVENT_KEY_MESSAGE] as? String else { return }
                TUITool.makeToast("error:\(errorCode):\(errorMessage)")
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return self.isStatusBarHidden
    }
    
    // MARK: SingleCallViewDelegate
    func handleStatusBarHidden(isHidden: Bool) {
        self.isStatusBarHidden = isHidden
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
}

class CallKitNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
