//
//  FloatWindowViewController.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/2.
//

import Foundation
import TUICore

class FloatWindowViewController: UIViewController, FloatingWindowViewDelegate {
    
    let callEventObserver = Observer()
    let floatView = FloatingWindowView(frame: CGRectZero)
    weak var delegate: FloatingWindowViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(floatView)
        floatView.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        floatView.delegate = self
        registerObserver()
    }
    
    deinit {
        TUICallState.instance.event.removeObserver(callEventObserver)
        for view in view.subviews {
            view.removeFromSuperview()
        }
    }
    
    //MARK: FloatingWindowViewDelegate
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("tapGestureAction")))) != nil) {
            self.delegate?.tapGestureAction(tapGesture: tapGesture)
        }
    }
    
    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("panGestureAction")))) != nil) {
            self.delegate?.panGestureAction(panGesture: panGesture)
        }
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
