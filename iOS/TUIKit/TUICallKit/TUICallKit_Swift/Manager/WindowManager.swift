//
//  WindowManager.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/21.
//

class WindowManager: NSObject, GestureViewDelegate {
    static let shared = WindowManager()

    private var floatWindowBeganPoint: CGPoint = .zero
    private let window: UIWindow = {
        let callWindow = UIWindow()
        callWindow.windowLevel = .alert - 1
        return callWindow
    }()

    private override init() {}
    
    // MARK: show calling Window
    func showCallingWindow() {
        Permission.hasPermission(callMediaType: CallManager.shared.callState.mediaType.value, fail: nil)
        CallManager.shared.viewState.router.value = .fullView
        window.rootViewController = CallKitNavigationController(rootViewController: CallMainViewController())
        window.frame = CGRect(x: 0, y: 0, width: Screen_Width, height: Screen_Height)
        window.isHidden = false
        window.backgroundColor = UIColor.black
        window.t_makeKeyAndVisible()
    }
    
    // MARK: show Floating Window
    func showFloatingWindow() {
        closeWindow()
        CallManager.shared.viewState.router.value = .floatView
        let vc = FloatWindowViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        window.rootViewController = vc
        window.frame = getFloatWindowFrame()
        window.isHidden = false
        window.backgroundColor = UIColor.clear
        window.t_makeKeyAndVisible()
    }
        
    // MARK: show Incoming Banner Window
    func showIncomingBannerWindow() {
        CallManager.shared.viewState.router.value = .banner
        window.rootViewController = IncomingBannerViewController(nibName: nil, bundle: nil)
        window.isHidden = false
        window.backgroundColor = UIColor.clear
        window.frame = CGRect(x: 8.scale375Width(),
                              y: StatusBar_Height + 10,
                              width: Screen_Width - 16.scale375Width(),
                              height: 92.scale375Width())
        window.t_makeKeyAndVisible()
    }
    
    // MARK: close windows
    func closeWindow() {
        CallManager.shared.viewState.router.value = .none
        window.rootViewController = nil
        window.isHidden = true
    }
    
    // MARK: GestureViewDelegate
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        guard FrameworkConstants.framework == FrameworkConstants.callFrameworkNative else { return }
        WindowManager.shared.showCallingWindow()
    }
    
    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            floatWindowBeganPoint = window.frame.origin
            break
        case.changed:
            let point = panGesture.translation(in: window)
            var dstX = floatWindowBeganPoint.x + point.x
            var dstY = floatWindowBeganPoint.y + point.y
            
            if dstX < 0 {
                dstX = 0
            } else if dstX > (Screen_Width - window.frame.size.width) {
                dstX = Screen_Width - window.frame.size.width
            }
            
            if dstY < 0 {
                dstY = 0
            } else if dstY > (Screen_Height - window.frame.size.height) {
                dstY = Screen_Height - window.frame.size.height
            }
            
            window.frame = CGRect(x: dstX,
                                       y: dstY,
                                       width: window.frame.size.width,
                                       height: window.frame.size.height)
            break
        case.cancelled:
            break
        case.ended:
            var dstX: CGFloat = 0
            let currentCenterX: CGFloat = window.frame.origin.x + window.frame.size.width / 2.0
            
            if currentCenterX < Screen_Width / 2 {
                dstX = CGFloat(0)
            } else if currentCenterX > Screen_Width / 2 {
                dstX = CGFloat(Screen_Width - window.frame.size.width)
            }
            
            window.frame = CGRect(x: dstX,
                                       y: window.frame.origin.y,
                                       width: window.frame.size.width,
                                       height: window.frame.size.height)
            break
        default:
            break
        }
    }
    
    // MARK: Private
    func getFloatWindowFrame() -> CGRect {
        if CallManager.shared.viewState.callingViewType.value == .multi {
            return kMicroGroupViewRect
        }
        
        if CallManager.shared.callState.mediaType.value == .audio {
            return kMicroAudioViewRect
        } else {
            return kMicroVideoViewRect
        }
    }
}
