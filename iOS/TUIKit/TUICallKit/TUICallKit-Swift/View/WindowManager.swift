//
//  WindowManger.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/22.
//

import Foundation

class WindowManager: NSObject, FloatingWindowViewDelegate {
    
    static let instance = WindowManager()
    
    var isFloating = false
    var floatWindowBeganPoint: CGPoint = .zero
    
    let mediaTypeObserver = Observer()
    
    let callWindow: UIWindow = {
        let callWindow = UIWindow()
        callWindow.windowLevel = .alert - 1
        return callWindow
    }()
    
    let floatWindow: UIWindow = {
        let floatWindow = UIWindow()
        floatWindow.windowLevel = .alert - 1
        floatWindow.layer.masksToBounds = true
        return floatWindow
    }()
    
    var callKitViewController: CallKitViewController?
    
    func getCallKitViewController() -> CallKitViewController {
        if let callKitViewController = callKitViewController {
            return callKitViewController
        } else {
            let newCallKitViewController = CallKitViewController()
            callKitViewController = newCallKitViewController
            return newCallKitViewController
        }
    }
    
    override init() {
        super.init()
        registerObserveState()
    }
    
    deinit {
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
    }
    
    func showCallWindow(_ isIncomingCall: Bool = true) {
        if isIncomingCall && TUICallState.instance.selfUser.value.callRole.value == .called {
            showIncomingFloatView()
        } else {
            showCallView()
        }
    }
    
    func closeCallWindow() {
        callKitViewController = nil
        callWindow.rootViewController = nil
        callWindow.isHidden = true
    }
    
    func showIncomingFloatView() {
        let viewController = UIViewController()
        viewController.view.addSubview(IncomingFloatView(frame: CGRect.zero))
        callWindow.rootViewController = viewController
        callWindow.isHidden = false
        callWindow.backgroundColor = UIColor.clear
        callWindow.frame = CGRect(x: 8.scaleWidth(),
                                  y: StatusBar_Height + 10,
                                  width: Screen_Width - 16.scaleWidth(),
                                  height: 92.scaleWidth())
        callWindow.t_makeKeyAndVisible()
    }
    
    func showCallView() {
        closeFloatWindow()
        callWindow.rootViewController = CallKitNavigationController(rootViewController: getCallKitViewController())
        callWindow.isHidden = false
        callWindow.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_Height)
        callWindow.t_makeKeyAndVisible()
    }
    
    func showFloatWindow() {
        closeCallWindow()
        let floatViewController = FloatWindowViewController()
        floatViewController.delegate = self
        floatWindow.rootViewController = floatViewController
        floatWindow.backgroundColor = UIColor.clear
        floatWindow.isHidden = false
        floatWindow.frame = getFloatWindowFrame()
        updateFloatWindowFrame()
        floatWindow.t_makeKeyAndVisible()
        isFloating = true
    }
    
    func closeFloatWindow() {
        floatWindow.rootViewController = nil
        floatWindow.isHidden = true
        isFloating = false
    }
    
    func getFloatWindowFrame() -> CGRect {
        if TUICallState.instance.scene.value == .group {
            return kMicroGroupViewRect
        }
        
        if TUICallState.instance.mediaType.value == .audio {
            return kMicroAudioViewRect
        } else {
            return kMicroVideoViewRect
        }
    }
    
    func updateFloatWindowFrame() {
        let originY = floatWindow.frame.origin.y
        
        if TUICallState.instance.scene.value == .group {
            let dstX = floatWindow.frame.origin.x < (Screen_Width / 2.0) ? 0 : (Screen_Width - kMicroGroupViewWidth)
            floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroGroupViewWidth, height: kMicroGroupViewHeight)
            return
        }
        
        if TUICallState.instance.mediaType.value == .audio {
            let dstX = floatWindow.frame.origin.x < (Screen_Width / 2.0) ? 0 : (Screen_Width - kMicroAudioViewWidth)
            floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroAudioViewWidth, height: kMicroAudioViewHeight)
        } else {
            let dstX = floatWindow.frame.origin.x < (Screen_Width / 2.0) ? 0 : (Screen_Width - kMicroVideoViewWidth)
            floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight)
        }
    }
    
    func registerObserveState() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.isFloating {
                self.updateFloatWindowFrame()
            }
        })
    }
    
    // MARK: FloatingWindowViewDelegate
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        showCallWindow(false)
    }
    
    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            floatWindowBeganPoint = floatWindow.frame.origin
            break
        case.changed:
            let point = panGesture.translation(in: floatWindow)
            var dstX = floatWindowBeganPoint.x + point.x
            var dstY = floatWindowBeganPoint.y + point.y
            
            if dstX < 0 {
                dstX = 0
            } else if dstX > (Screen_Width - floatWindow.frame.size.width) {
                dstX = Screen_Width - floatWindow.frame.size.width
            }
            
            if dstY < 0 {
                dstY = 0
            } else if dstY > (Screen_Height - floatWindow.frame.size.height) {
                dstY = Screen_Height - floatWindow.frame.size.height
                
            }
            
            floatWindow.frame = CGRect(x: dstX,
                                       y: dstY,
                                       width: floatWindow.frame.size.width,
                                       height: floatWindow.frame.size.height)
            break
        case.cancelled:
            break
        case.ended:
            var dstX: CGFloat = 0
            let currentCenterX: CGFloat = floatWindow.frame.origin.x + floatWindow.frame.size.width / 2.0
            
            if currentCenterX < Screen_Width / 2 {
                dstX = CGFloat(0)
            } else if currentCenterX > Screen_Width / 2 {
                dstX = CGFloat(Screen_Width - floatWindow.frame.size.width)
            }
            
            floatWindow.frame = CGRect(x: dstX,
                                       y: floatWindow.frame.origin.y,
                                       width: floatWindow.frame.size.width,
                                       height: floatWindow.frame.size.height)
            break
        default:
            break
        }
    }
}
