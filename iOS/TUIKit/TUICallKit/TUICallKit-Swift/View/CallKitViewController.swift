//
//  CallKitViewController.swift
//  Alamofire
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import UIKit
import TUICore

class CallKitViewController: UIViewController {
    
    let callEventObserver = Observer()
        
    deinit {
        TUICallState.instance.event.removeObserver(callEventObserver)
    }
        
    override func viewDidLoad(){
        super.viewDidLoad()
        if TUICallState.instance.scene.value == .single {
            let callView: SingleCallView? = SingleCallView(frame: CGRectZero)
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
            } else if newValue.eventType == .TIP {
                
                switch newValue.event {
                case .USER_EXCEED_LIMIT:
                    guard let userId = newValue.param[EVENT_KEY_USER_ID] as? String else { return }
                    guard let toastString = TUICallKitLocalize(key: "Demo.TRTC.Calling.User.Exceed.Limit") else { return }
                    TUITool.makeToast(userId + toastString)
                    
                case .USER_NO_RESPONSE:
                    guard let userId = newValue.param[EVENT_KEY_USER_ID] as? String else { return }
                    guard let toastString = TUICallKitLocalize(key: "Demo.TRTC.calling.callingnoresponse") else { return }
                    TUITool.makeToast(userId + toastString)

                case .USER_LINE_BUSY:
                    guard let userId = newValue.param[EVENT_KEY_USER_ID] as? String else { return }
                    guard let toastString = TUICallKitLocalize(key: "Demo.TRTC.calling.callingbusy") else { return }
                    TUITool.makeToast(userId + toastString)

                case .USER_REJECT:
                    guard let userId = newValue.param[EVENT_KEY_USER_ID] as? String else { return }
                    guard let toastString = TUICallKitLocalize(key: "Demo.TRTC.calling.callingrefuse") else { return }
                    TUITool.makeToast(userId + toastString)

                case .USER_LEAVE:
                    guard let userId = newValue.param[EVENT_KEY_USER_ID] as? String else { return }
                    guard let toastString = TUICallKitLocalize(key: "Demo.TRTC.calling.callingleave") else { return }
                    TUITool.makeToast(userId + toastString)

                default:
                    break
                }
            }
        }
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
