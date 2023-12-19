//
//  FloatWindowViewController.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/2.
//

import Foundation
import TUICore

protocol FloatingWindowViewDelegate: NSObject {
    func tapGestureAction(tapGesture: UITapGestureRecognizer)
    func panGestureAction(panGesture: UIPanGestureRecognizer)
}

class FloatWindowViewController: UIViewController, FloatingWindowViewDelegate {
    
    let callEventObserver = Observer()
    weak var delegate: FloatingWindowViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if TUICallState.instance.scene.value == .group {
            addFloatingWindowGroupView()
        } else if TUICallState.instance.scene.value == .single {
            addFloatingWindowSignalView()
        }
        
        registerObserver()
    }
    
    deinit {
        TUICallState.instance.event.removeObserver(callEventObserver)
        for view in view.subviews {
            view.removeFromSuperview()
        }
    }
    
    func addFloatingWindowGroupView() {
        let floatView = FloatingWindowGroupView(frame: CGRect.zero)
        view.addSubview(floatView)
        floatView.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        floatView.delegate = self
    }
    
    func addFloatingWindowSignalView() {
        let floatView = FloatingWindowSignalView(frame: CGRect.zero)
        view.addSubview(floatView)
        floatView.snp.makeConstraints { make in
            make.center.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        floatView.delegate = self
    }
    
    // MARK: FloatingWindowViewDelegate
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
            }
        }
    }
    
}
