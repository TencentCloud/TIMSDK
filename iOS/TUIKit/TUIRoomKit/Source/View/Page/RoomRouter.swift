//
//  RoomRouter.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2022/9/30.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore
import TUIRoomEngine

// 视图路由上下文
class RouteContext {
    var rootNavigation: RoomKitNavigationController? // 当前根视图控制器
    typealias WeakArray<T> = [() -> T?]
    var presentControllerMap: [PopUpViewType:WeakArray<UIViewController>] = [:] //当前模态弹出的页面
    let appearance: UINavigationBarAppearance = UINavigationBarAppearance()
    let navigationDelegate = RoomRouter.RoomNavigationDelegate()
    var chatWindow : UIWindow?
    var currentLandscape: Bool = isLandscape
    init() {}
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
    
    var navController: RoomKitNavigationController? {
        return context.rootNavigation
    }
    
    private func subscribeUIEvent() {
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ShowRoomMainView, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ShowRoomVideoFloatView, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_HiddenChatWindow, responder: self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    private func unsubscribeEvent() {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ShowRoomMainView, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ShowRoomVideoFloatView, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_HiddenChatWindow, responder: self)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func hasChatWindow() -> Bool {
        return context.chatWindow != nil
    }
    
    func pushToChatController(user: UserEntity, roomInfo: TUIRoomInfo) {
        guard let chatVC = makeChatController(user: user, roomInfo: roomInfo) else { return }
        let appearance = context.appearance
        appearance.backgroundColor = UIColor.white
        let nav = !isLandscape ? navController : UINavigationController(rootViewController: chatVC)
        nav?.navigationBar.standardAppearance = appearance
        nav?.navigationBar.scrollEdgeAppearance = appearance
        nav?.navigationBar.tintColor = UIColor.black
        if !isLandscape {
            push(viewController: chatVC)
        } else {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            let chatWidth = min(kScreenWidth, kScreenHeight)
            context.chatWindow = UIWindow(windowScene: windowScene)
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
        ]
        return TUICore.createObject(TUICore_TUIChatObjectFactory, key: TUICore_TUIChatObjectFactory_ChatViewController_Classic,
                                    param: param) as? UIViewController
    }
    
    func pushMainViewController(roomId: String) {
        let vc = makeMainViewController(roomId: roomId)
        push(viewController: vc)
    }
    
    func presentPopUpViewController(viewType: PopUpViewType, height: CGFloat, backgroundColor: UIColor = UIColor(0x1B1E26)) {
        let vc = makePopUpViewController(viewType: viewType, height: height, backgroundColor: backgroundColor)
        let weakObserver = { [weak vc] in return vc }
        if var observerArray = context.presentControllerMap[viewType] {
            observerArray.append(weakObserver)
            context.presentControllerMap[viewType] = observerArray
        } else {
            context.presentControllerMap[viewType] = [weakObserver]
        }
        present(viewController: vc)
    }
    
    func dismissPopupViewController(viewType: PopUpViewType, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard var observerArray = context.presentControllerMap[viewType] else { return }
        guard observerArray.count > 0 else {
            context.presentControllerMap.removeValue(forKey: viewType)
            return
        }
        guard let observer = observerArray.last, let vc = observer() else { return }
        vc.dismiss(animated: animated, completion: completion)
        observerArray.removeLast()
        if observerArray.count == 0 {
            context.presentControllerMap.removeValue(forKey: viewType)
        }
    }
    
    //删除所有进房后的popupViewController
    func dismissAllRoomPopupViewController() {
        for viewType in context.presentControllerMap.keys {
            if viewType == .navigationControllerType { continue }
            guard let observerArray = context.presentControllerMap[viewType] else { continue }
            guard observerArray.count > 0 else {
                context.presentControllerMap.removeValue(forKey: viewType)
                continue
            }
            observerArray.forEach { observer in
                if let vc = observer() as? PopUpViewController {
                    vc.viewModel.searchControllerActiveChange()
                }
                observer()?.dismiss(animated: true)
            }
            context.presentControllerMap.removeValue(forKey: viewType)
        }
    }
    
    func pop(animated: Bool = true) {
        guard let viewControllerArray = navController?.viewControllers else { return }
        if viewControllerArray.count <= 1 {
            navController?.dismiss(animated: true)
            context.rootNavigation = nil
            context.presentControllerMap.removeValue(forKey: .navigationControllerType)
        } else {
            navController?.popViewController(animated: animated)
        }
    }
    
    func popToRoomEntranceViewController() {
        guard let navController = navController else { return }
        var controllerArray = navController.viewControllers
        controllerArray.reverse()
        for vc in controllerArray {
            if vc is PopUpViewController {
                vc.dismiss(animated: true)
            } else {
                pop()
            }
            if vc is RoomMainViewController {
                break
            }
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
    }
    
    class func makeToast(toast: String) {
        shared.getCurrentWindowViewController()?.view.makeToast(toast)
    }
    
    class func makeToastInCenter(toast: String, duration:TimeInterval) {
        guard let windowView = shared.getCurrentWindowViewController()?.view else {return}
        windowView.makeToast(toast,duration: duration,position:TUICSToastPositionCenter)
    }
    
    class func getCurrentWindow() -> UIWindow? {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let keyWindow = windowScene.windows.first {
                return keyWindow
            }
        }
        return UIApplication.shared.windows.first(where: { $0.windowLevel == .normal && $0.isHidden == false &&
            CGRectEqualToRect($0.bounds , UIScreen.main.bounds )})
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
    
    private func push(viewController: UIViewController, animated: Bool = true) {
        guard let navController = navController else {
            createRootNavigationAndPresent(controller: viewController)
            return
        }
        navController.pushViewController(viewController, animated: animated)
    }
    
    private func present(viewController: UIViewController, style: UIModalPresentationStyle = .automatic, animated: Bool = true) {
        viewController.modalPresentationStyle = style
        guard let navController = navController else { return }
        navController.present(viewController, animated: animated)
    }
    
    private func createRootNavigationAndPresent(controller: UIViewController) {
        let navigationController = RoomKitNavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        context.rootNavigation = navigationController
        if #available(iOS 13.0, *) {
            setupNavigationBarAppearance()
            navigationController.navigationBar.standardAppearance = context.appearance
            navigationController.navigationBar.scrollEdgeAppearance = context.appearance
        }
        navigationController.delegate = context.navigationDelegate
        let weakObserver = { [weak navigationController] in
            return navigationController
        }
        if var observerArray = context.presentControllerMap[.navigationControllerType] {
            observerArray.append(weakObserver)
            context.presentControllerMap[.navigationControllerType] = observerArray
        } else {
            context.presentControllerMap[.navigationControllerType] = [weakObserver]
        }
        guard let controller = getCurrentWindowViewController() else { return }
        controller.present(navigationController, animated: true)
    }
    
    @available(iOS 13.0, *)
    private func setupNavigationBarAppearance() {
        let barAppearance = context.appearance
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
    
    private func makeMainViewController(roomId: String) -> UIViewController {
        let controller = RoomMainViewController(roomMainViewModelFactory: self)
        return controller
    }
    
    private func makePopUpViewController(viewType: PopUpViewType, height: CGFloat, backgroundColor: UIColor) -> UIViewController {
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
        if viewController is RoomMainViewController {
            let appearance = RoomRouter.shared.context.appearance
            appearance.backgroundColor = UIColor(0x1B1E26)
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            navigationController.navigationBar.tintColor = UIColor.white
        }
    }
}

extension RoomRouter: RoomMainViewModelFactory {
    func makeRoomMainViewModel() -> RoomMainViewModel {
        let model = RoomMainViewModel()
        return model
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
            dismissAllRoomPopupViewController()
            popToRoomEntranceViewController()
            RoomVideoFloatView.show()
        case .TUIRoomKitService_ShowRoomMainView:
            RoomVideoFloatView.dismiss()
            self.pushMainViewController(roomId: EngineManager.createInstance().store.roomInfo.roomId)
        case .TUIRoomKitService_HiddenChatWindow:
            destroyChatWindow()
        default: break
        }
    }
}

private extension String {
    static var chatText: String {
        localized("TUIRoom.chat")
    }
}
