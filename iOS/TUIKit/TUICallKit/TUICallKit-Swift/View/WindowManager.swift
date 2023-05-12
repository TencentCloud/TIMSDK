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
    
    let mediaTypeObserver = Observer()
    let remoteUserListObserver = Observer()
    
    let callWindow = UIWindow()
    let floatWindow = UIWindow()
    
    var floatWindowBeganPoint: CGPoint?
    var floatWindowBeganOrigin: CGPoint?
    
    override init() {
        super.init()
        registerObserveState()
    }
    
    deinit {
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.timeCount.removeObserver(mediaTypeObserver)
    }
    
    func showCallWindow() {
        closeFloatWindow()
        callWindow.rootViewController =  CallKitNavigationController(rootViewController: CallKitViewController())
        callWindow.isHidden = false
        callWindow.t_makeKeyAndVisible()
    }
    
    func closeCallWindow() {
        callWindow.rootViewController = UIViewController()
        callWindow.isHidden = true
    }
    
    func showFloatWindow() {
        closeCallWindow()
        floatWindow.frame = getFloatWindowFrame()
        floatWindow.backgroundColor = UIColor.t_colorWithHexString(color: "#F2F2F2")
        let floatViewController = FloatWindowViewController()
        floatViewController.delegate = self
        floatWindow.rootViewController = floatViewController
        floatWindow.isHidden = false
        floatWindow.t_makeKeyAndVisible()
        isFloating = true
        updateFloatWindowFrame()
    }
    
    func closeFloatWindow() {
        floatWindow.rootViewController = UIViewController()
        floatWindow.isHidden = true
        isFloating = false
    }
    
    func getFloatWindowFrame() -> CGRect {
        if TUICallState.instance.mediaType.value == .audio {
            return kMicroAudioViewRect
        } else {
            if TUICallState.instance.remoteUserList.value.first != nil {
                if TUICallState.instance.remoteUserList.value[0].videoAvailable.value {
                    return kMicroVideoViewRect
                } else {
                    return kMicroVideoDisAvailableViewRect
                }
            }
        }
        return kMicroVideoViewRect
    }
    
    func updateFloatWindowFrame() {
        let originY = floatWindow.frame.origin.y
        if TUICallState.instance.scene.value == .single {
            if TUICallState.instance.mediaType.value == .audio {
                let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? 0 : Screen_Width - kMicroAudioViewWidth
                floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroAudioViewWidth, height: kMicroAudioViewHeight)
            } else {
                let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? 0 : Screen_Width - kMicroVideoViewWidth
                if TUICallState.instance.remoteUserList.value.first != nil {
                    if TUICallState.instance.remoteUserList.value[0].videoAvailable.value {
                        floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight)
                    } else {
                        floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight - 10)
                    }
                }
            }
        } else {
            let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? 0 : Screen_Width - kMicroAudioViewWidth
            floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroAudioViewWidth, height: kMicroAudioViewHeight)
        }
    }
    
    func registerObserveState() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateFloatWindowFrame()
        })
    }
    
    //MARK: FloatingWindowViewDelegate
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        showCallWindow()
    }

    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            floatWindowBeganPoint = floatWindow.frame.origin
            floatWindowBeganOrigin = floatWindow.frame.origin
            break
        case.changed:
            let point = panGesture.translation(in: floatWindow)
            var dstX = (floatWindowBeganPoint?.x ?? 0) + CGFloat(point.x)
            var dstY = (floatWindowBeganPoint?.y ?? 0) + CGFloat(point.y)
            
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
            if floatWindow.frame.origin.x < Screen_Width / 2 {
                dstX = CGFloat(0)
            } else if floatWindow.frame.origin.x > Screen_Width / 2 {
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

