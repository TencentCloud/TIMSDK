//
//  RoomRouter.swift
//  TUIRoomKit
//
//  Created by janejntang on 2022/9/30.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore
import RTCRoomEngine

// View routing context
class RouteContext {
    var rootNavigation: UINavigationController?
    typealias Weak<T> = () -> T?
    var alterControllers: [Weak<UIViewController>] = []
    var popUpViewController: Weak<PopUpViewController>?
    var appearance: AnyObject?
    let navigationDelegate = RoomRouter.RoomNavigationDelegate()
    var chatWindow : UIWindow?
    var currentLandscape: Bool = isLandscape
    weak var rootViewController: UIViewController?
    init() {
        if #available(iOS 13, *) {
            appearance = UINavigationBarAppearance()
        }
    }
}

class RoomRouter: NSObject {
    static let shared = RoomRouter()
    private let context: RouteContext = RouteContext()
    private override init() {
        super.init()
        subscribeUIEvent()
    }
    
    class RoomNavigationDelegate: NSObject {
        
    }
    
    var navController: UINavigationController? {
        return context.rootNavigation
    }
    
    private func subscribeUIEvent() {
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ShowRoomMainView, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ShowRoomVideoFloatView, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_HiddenChatWindow, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, responder: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func unsubscribeEvent() {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ShowRoomMainView, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ShowRoomVideoFloatView, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_HiddenChatWindow, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, responder: self)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func hasChatWindow() -> Bool {
        return context.chatWindow != nil
    }
    
    func pushToChatController(user: UserEntity, roomInfo: TUIRoomInfo) {
        guard let chatVC = makeChatController(user: user, roomInfo: roomInfo) else { return }
        let nav = !isLandscape ? navController : UINavigationController(rootViewController: chatVC)
        if !isLandscape {
            push(viewController: chatVC, animated: false)
        } else {
            if #available(iOS 13, *) {
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
                context.chatWindow = UIWindow(windowScene: windowScene)
            } else {
                context.chatWindow = UIWindow(frame: UIScreen.main.bounds)
            }
            let chatWidth = min(kScreenWidth, kScreenHeight)
            context.chatWindow?.frame = CGRect(x: kScreenWidth - chatWidth - kDeviceSafeBottomHeight, y: 0, width: chatWidth, height: chatWidth)
            context.chatWindow?.rootViewController = nav
            context.chatWindow?.windowLevel = UIWindow.Level.statusBar + 1
            context.chatWindow?.isHidden = false
            context.chatWindow?.makeKeyAndVisible()
        }
    }
    
    func makeChatController(user: UserEntity, roomInfo: TUIRoomInfo) -> UIViewController? {
        let config: [String : Any] = [
            TUICore_TUIChatService_SetChatExtensionMethod_EnableVideoCallKey: false,
            TUICore_TUIChatService_SetChatExtensionMethod_EnableAudioCallKey: false,
            TUICore_TUIChatService_SetChatExtensionMethod_EnableLinkKey: false,
        ]
        TUICore.callService(TUICore_TUIChatService, method: TUICore_TUIChatService_SetChatExtensionMethod, param: config)
        let maxSizeKey = "TUICore_TUIChatService_SetMaxTextSize"
        let chatWidth = min(kScreenWidth, kScreenHeight)
        let sizeParam : [String : Any] = ["maxsize": CGSize(width: chatWidth - 150, height: Double(MAXFLOAT))]
        TUICore.callService(TUICore_TUIChatService, method: maxSizeKey, param: sizeParam)
        let param : [String : Any] = [
            TUICore_TUIChatObjectFactory_ChatViewController_Title : String.chatText,
            TUICore_TUIChatObjectFactory_ChatViewController_GroupID: roomInfo.roomId,
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : user.avatarUrl,
            TUICore_TUIChatObjectFactory_ChatViewController_Enable_Video_Call : String(0),
            TUICore_TUIChatObjectFactory_ChatViewController_Enable_Audio_Call : String(0),
            TUICore_TUIChatObjectFactory_ChatViewController_Enable_Room : String(0),
            TUICore_TUIChatObjectFactory_ChatViewController_Limit_Portrait_Orientation: String(1),
            TUICore_TUIChatObjectFactory_ChatViewController_Enable_Poll  : String(0),
            TUICore_TUIChatObjectFactory_ChatViewController_Enable_GroupNote  : String(0),
            TUICore_TUIChatObjectFactory_ChatViewController_Enable_WelcomeCustomMessage :String(0),
            TUICore_TUIChatObjectFactory_ChatViewController_Enable_TakePhoto :String(0),
            TUICore_TUIChatObjectFactory_ChatViewController_Enable_RecordVideo :String(0),
        ]
        return TUICore.createObject(TUICore_TUIChatObjectFactory, key: TUICore_TUIChatObjectFactory_ChatViewController_Classic,
                                    param: param) as? UIViewController
    }
    
    func pushMainViewController() {
        let vc = makeMainViewController()
        push(viewController: vc)
    }
    
    func presentPopUpViewController(viewType: PopUpViewType, height: CGFloat, backgroundColor: UIColor = UIColor(0x1B1E26)) {
        if let observer = context.popUpViewController, let vc = observer() {
            vc.dismiss(animated: false)
        }
        let vc = makePopUpViewController(viewType: viewType, height: height, backgroundColor: backgroundColor)
        let weakObserver = { [weak vc] in return vc }
        context.popUpViewController = weakObserver
        present(viewController: vc)
    }
    
    func dismissPopupViewController(completion: (() -> Void)? = nil) {
        guard let observer = context.popUpViewController, let vc = observer() else {
            completion?()
            return
        }
        vc.viewModel.changeSearchControllerActive()
        vc.dismiss(animated: true, completion: completion)
        context.popUpViewController = nil
    }
    
    func pop(animated: Bool = true) {
        guard let viewControllerArray = navController?.viewControllers else { return }
        if viewControllerArray.count <= 1 {
            viewControllerArray.first?.dismiss(animated: true)
            navController?.dismiss(animated: true)
            context.rootNavigation = nil
        } else {
            if let vc = viewControllerArray.last, vc is ConferenceMainViewController {                
                navController?.popViewController(animated: animated)
                context.rootNavigation = nil
            } else {
                navController?.popViewController(animated: animated)
            }
        }
    }
    
    func popToRoomEntranceViewController() {
        if let navController = navController {
            var controllerArray = navController.viewControllers
            controllerArray.reverse()
            for vc in controllerArray {
                if vc is PopUpViewController {
                    vc.dismiss(animated: true)
                } else {
                    pop()
                }
                if vc is ConferenceMainViewController {
                    break
                }
            }
        } else if let vc = context.rootViewController {
            vc.dismiss(animated: true)
        }
    }
    
    class func presentAlert(title: String?, message: String?, sureTitle:String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?) {
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        if let declineTitle = declineTitle {
            let declineAction = UIAlertAction(title: declineTitle, style: .destructive) { _ in
                declineBlock?()
            }
            declineAction.setValue(UIColor(0x4F586B), forKey: "titleTextColor")
            alertVC.addAction(declineAction)
        }
        let sureAction = UIAlertAction(title: sureTitle, style: .default) { _ in
            sureBlock?()
        }
        alertVC.addAction(sureAction)
        shared.getCurrentWindowViewController()?.present(alertVC, animated: true)
        let weakObserver = { [weak alertVC] in return alertVC }
        shared.context.alterControllers.append(weakObserver)
    }
    
    func dismissAllAlertController(complete: @escaping (()->())) {
        guard context.alterControllers.count > 0 else {
            complete()
            return
        }
        dismissAlertController(index: context.alterControllers.count - 1) { [weak self] in
            guard let self = self else { return }
            self.context.alterControllers = []
            complete()
        }
    }
    
    private func dismissAlertController(index: Int, complete: @escaping (()->())) {
        if index < 0 {
            complete()
            return
        }
        if let observer = context.alterControllers[safe: index], let vc = observer() {
            vc.dismiss(animated: true) { [weak self] in
                guard let self = self else { return }
                self.dismissAlertController(index: index - 1, complete: complete)
            }
        } else {
            dismissAlertController(index: index-1, complete: complete)
        }
    }
     
    
    class func makeToast(toast: String) {
        shared.getCurrentWindowViewController()?.view.makeToast(toast)
    }
    
    class func makeToastInCenter(toast: String, duration:TimeInterval) {
        guard let windowView = shared.getCurrentWindowViewController()?.view else {return}
        windowView.makeToast(toast,duration: duration,position:TUICSToastPositionCenter)
    }
    
    class func makeToastInWindow(toast: String, duration:TimeInterval) {
        guard let window = RoomRouter.getCurrentWindow() else {return}
        window.makeToast(toast,duration: duration,position:TUICSToastPositionCenter)
    }
    
    class func getCurrentWindow() -> UIWindow? {
        var windows: [UIWindow]
        if #available(iOS 13.0, *), let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windows = windowScene.windows
        } else {
            windows = UIApplication.shared.windows
        }
        if let keyWindow = windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        } else {
            return windows.last(where: { $0.windowLevel == .normal && $0.isHidden == false &&
                CGRectEqualToRect($0.bounds , UIScreen.main.bounds) })
        }
    }
    
    func initializeNavigationController(rootViewController: UIViewController) {
        guard context.rootNavigation == nil else { return }
        if let nav = rootViewController.navigationController {
            context.rootNavigation = nav
        }
        context.rootViewController = rootViewController
    }
    
    @objc func handleDeviceOrientationChange() {
        guard context.currentLandscape != isLandscape else { return }
        destroyChatWindow()
        context.currentLandscape = isLandscape
    }
    
    deinit {
        unsubscribeEvent()
        debugPrint("deinit \(self)")
    }
}

extension RoomRouter {
    
    func push(viewController: UIViewController, animated: Bool = true) {
        guard let navController = navController else {
            createRootNavigationAndPresent(controller: viewController)
            return
        }
        navController.pushViewController(viewController, animated: animated)
    }
    
    private func present(viewController: UIViewController, animated: Bool = true) {
        if #available(iOS 13.0, *) {
            viewController.modalPresentationStyle = .automatic
        } else {
            viewController.modalPresentationStyle = .overFullScreen
        }
        if let navController = navController {
            navController.present(viewController, animated: animated)
        } else if let vc = context.rootViewController {
            vc.present(viewController, animated: true)
        }
    }
    
    private func createRootNavigationAndPresent(controller: UIViewController) {
        let navigationController = RoomKitNavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        context.rootNavigation = navigationController
        if #available(iOS 13.0, *) {
            setupNavigationBarAppearance()
            if let appearance = context.appearance as? UINavigationBarAppearance {
                navigationController.navigationBar.standardAppearance = appearance
                navigationController.navigationBar.scrollEdgeAppearance = appearance
            }
        } else {
            navigationController.navigationBar.barTintColor = UIColor(0x1B1E26)
            navigationController.navigationBar.shadowImage = UIImage()
            navigationController.navigationBar.barStyle = .default
        }
        navigationController.delegate = context.navigationDelegate
        let weakObserver = { [weak navigationController] in
            return navigationController
        }
        guard let controller = getCurrentWindowViewController() else { return }
        controller.present(navigationController, animated: true)
    }
    
    @available(iOS 13.0, *)
    private func setupNavigationBarAppearance() {
        guard let barAppearance = context.appearance as? UINavigationBarAppearance else {
            return
        }
        barAppearance.configureWithDefaultBackground()
        barAppearance.shadowColor = nil
        barAppearance.backgroundEffect = nil
        barAppearance.backgroundColor = UIColor(0x1B1E26)
    }
    
    private func getCurrentWindowViewController() -> UIViewController? {
        var keyWindow: UIWindow?
        for window in UIApplication.shared.windows {
            if window.isMember(of: UIWindow.self), window.isKeyWindow {
                keyWindow = window
                break
            }
        }
        guard let rootController = keyWindow?.rootViewController else {
            return nil
        }
        func findCurrentController(from vc: UIViewController?) -> UIViewController? {
            if let nav = vc as? UINavigationController {
                return findCurrentController(from: nav.topViewController)
            } else if let tabBar = vc as? UITabBarController {
                return findCurrentController(from: tabBar.selectedViewController)
            } else if let presented = vc?.presentedViewController {
                return findCurrentController(from: presented)
            }
            return vc
        }
        let viewController = findCurrentController(from: rootController)
        return viewController
    }
    
    private func makeMainViewController() -> UIViewController {
        let controller = ConferenceMainViewController()
        return controller
    }
    
    private func makePopUpViewController(viewType: PopUpViewType, height: CGFloat, backgroundColor: UIColor) -> PopUpViewController {
        let controller = PopUpViewController(popUpViewModelFactory: self, viewType: viewType, height: height, backgroundColor: backgroundColor)
        return controller
    }
    
    private func destroyChatWindow() {
        guard context.chatWindow != nil else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.context.chatWindow = nil
        }
    }
}

extension RoomRouter.RoomNavigationDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController is ConferenceMainViewController {
            if #available(iOS 13.0, *) {
                if let appearance = RoomRouter.shared.context.appearance as? UINavigationBarAppearance {
                    appearance.backgroundColor = UIColor(0x1B1E26)
                    navigationController.navigationBar.standardAppearance = appearance
                    navigationController.navigationBar.scrollEdgeAppearance = appearance
                    navigationController.navigationBar.tintColor = UIColor.white
                }
            } else {
                navigationController.navigationBar.tintColor = UIColor.white
                navigationController.navigationBar.backgroundColor = UIColor(0x1B1E26)
            }
        }
    }
}

extension RoomRouter: PopUpViewModelFactory {
    func makeRootViewModel(viewType: PopUpViewType, height: CGFloat, backgroundColor: UIColor) -> PopUpViewModel {
        let viewModel = PopUpViewModel(viewType: viewType, height: height)
        viewModel.backgroundColor = backgroundColor
        return viewModel
    }
}

extension RoomRouter: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_ShowRoomVideoFloatView:
            dismissPopupViewController()
            popToRoomEntranceViewController()
            RoomVideoFloatView.show()
        case .TUIRoomKitService_ShowRoomMainView:
            RoomVideoFloatView.dismiss()
            self.pushMainViewController()
        case .TUIRoomKitService_HiddenChatWindow:
            destroyChatWindow()
        case .TUIRoomKitService_DismissConferenceViewController:
            dismissAllAlertController() { [weak self] in
                guard let self = self else { return }
                self.dismissPopupViewController() { [weak self] in
                    guard let self = self else { return }
                    self.popToRoomEntranceViewController()
                }
            }
        default: break
        }
    }
}

private extension String {
    static var chatText: String {
        localized("Chat")
    }
}
