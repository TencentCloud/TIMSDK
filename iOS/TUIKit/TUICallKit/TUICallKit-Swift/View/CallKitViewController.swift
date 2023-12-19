//
//  CallKitViewController.swift
//  TUICallKit
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
            let callView: SingleCallView? = SingleCallView(frame: CGRect.zero)
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
