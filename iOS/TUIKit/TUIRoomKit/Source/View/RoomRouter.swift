//
//  RoomRouter.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2022/9/30.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore

// 视图路由上下文
class RouteContext {
    var rootNavigation: RoomKitNavigationController? // 当前根视图控制器
    typealias WeakArray<T> = [() -> T?]
    var presentControllerMap: [PopUpViewType:WeakArray<UIViewController>] = [:] //当前模态弹出的页面
    let appearance: UINavigationBarAppearance = UINavigationBarAppearance()
    let navigationDelegate = RoomRouter.RoomNavigationDelegate()
    weak var chatViewController: UIViewController? // 当前聊天视图控制器
    init() {}
}

class RoomRouter {
    static let shared = RoomRouter()
    private let context: RouteContext = RouteContext()
    private init() {}
    
    class RoomNavigationDelegate: NSObject {
        
    }
    
    var navController: RoomKitNavigationController? {
        return context.rootNavigation
    }
    
    func pushToChatController(user: UserModel, roomInfo: RoomInfo) {
        let config: [String : Any] = [
            TUICore_TUIChatService_SetChatExtensionMethod_EnableVideoCallKey: false,
            TUICore_TUIChatService_SetChatExtensionMethod_EnableAudioCallKey: false,
            TUICore_TUIChatService_SetChatExtensionMethod_EnableLinkKey: false,
        ]
        TUICore.callService(TUICore_TUIChatService, method: TUICore_TUIChatService_SetChatExtensionMethod, param: config)
        let param : [String : Any] = [
            TUICore_TUIChatObjectFactory_ChatViewController_Title : roomInfo.name,
            TUICore_TUIChatObjectFactory_ChatViewController_GroupID: roomInfo.roomId,
            TUICore_TUIChatObjectFactory_ChatViewController_AvatarUrl : user.avatarUrl,
        ]
        if let chatVC = TUICore.createObject(TUICore_TUIChatObjectFactory, key: TUICore_TUIChatObjectFactory_ChatViewController_Classic,
                                             param: param) as? UIViewController {
            context.chatViewController = chatVC
            let appearance = context.appearance
            appearance.backgroundColor = UIColor.white
            guard let navController = navController else {
                push(viewController: chatVC)
                return
            }
            navController.navigationBar.standardAppearance = appearance
            navController.navigationBar.scrollEdgeAppearance = appearance
            navController.navigationBar.tintColor = UIColor.black
            push(viewController: chatVC)
        }
    }
    
    func pushPrePareViewController(enablePrePareView: Bool) {
        let prepareVC = makePrePareViewController(enablePrepareView: enablePrePareView)
        createRootNavigationAndPresent(controller: prepareVC)
    }
    
    func pushMainViewController(roomId: String) {
        let vc = makeMainViewController(roomId: roomId)
        push(viewController: vc)
    }
    
    func pushCreateRoomViewController() {
        let createRoomVC = makeCreateRoomViewController()
        push(viewController: createRoomVC)
    }
    
    func pushJoinRoomViewController() {
        let joinRoomVC = makeJoinRoomViewController()
        push(viewController: joinRoomVC)
    }
    
    func presentPopUpViewController(viewType: PopUpViewType, height: CGFloat?, backgroundColor: UIColor = UIColor(0x1B1E26)) {
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
    
    func presentAlert(_ alertController: UIAlertController) {
        getCurrentWindowViewController()?.present(alertController, animated: true)
    }
    
    class func makeToast(toast: String) {
        shared.getCurrentWindowViewController()?.view.makeToast(toast)
    }
    
    deinit {
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
    
    private func makePrePareViewController(enablePrepareView: Bool) -> UIViewController {
        let viewController = RoomPrePareViewController(roomPrePareViewModelFactory: self, enablePrepareView: enablePrepareView)
        return viewController
    }
    
    private func makeMainViewController(roomId: String) -> UIViewController {
        let controller = RoomMainViewController(roomMainViewModelFactory: self)
        return controller
    }
    
    private func makeCreateRoomViewController() -> UIViewController {
        let controller = RoomEntranceViewController(roomMainViewModelFactory: self, isCreateRoom: true)
        return controller
    }
    
    private func makeJoinRoomViewController() -> UIViewController {
        let controller = RoomEntranceViewController(roomMainViewModelFactory: self, isCreateRoom: false)
        return controller
    }
    
    private func makePopUpViewController(viewType: PopUpViewType, height: CGFloat?, backgroundColor: UIColor) -> UIViewController {
        let controller = PopUpViewController(popUpViewModelFactory: self, viewType: viewType, height: height, backgroundColor: backgroundColor)
        return controller
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

extension RoomRouter: RoomPrePareViewModelFactory {
    func makePrePareViewModel(enablePrepareView: Bool) -> PrePareViewModel {
        let model = PrePareViewModel()
        model.enablePrePareView = enablePrepareView
        return model
    }
}

extension RoomRouter: RoomMainViewModelFactory {
    func makeRoomMainViewModel() -> RoomMainViewModel {
        let model = RoomMainViewModel()
        return model
    }
}

extension RoomRouter: RoomEntranceViewModelFactory {
    func makeRootView(isCreateRoom: Bool) -> UIView {
        if isCreateRoom {
            let model = CreateRoomViewModel()
            return CreateRoomView(viewModel: model)
        } else {
            let model = EnterRoomViewModel()
            return EnterRoomView(viewModel: model)
        }
    }
}

extension RoomRouter: PopUpViewModelFactory {
    func makeRootViewModel(viewType: PopUpViewType, height: CGFloat?, backgroundColor: UIColor) -> PopUpViewModel {
        let viewModel = PopUpViewModel(viewType: viewType, height: height)
        viewModel.backgroundColor = backgroundColor
        return viewModel
    }
}
