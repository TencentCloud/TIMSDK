//
//  ConferenceRoute.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/19.
//

import Combine

protocol Route: ActionDispatcher {
    func initializeRoute(viewController: UIViewController, rootRoute: ConferenceRoute)
    func uninitialize()
    func pushTo(route: ConferenceRoute)
    func present(route: ConferenceRoute)
    func dismiss(animated: Bool)
    func pop()
    func popTo(route: ConferenceRoute)
    func pop(route: ConferenceRoute) 
    func showContactView(delegate: ContactViewSelectDelegate, participants: ConferenceParticipants)
}

private let currentRouteActionSelector = Selector(keyPath: \ConferenceRouteState.currentRouteAction)
private let memberSelectFactorySelector = Selector(keyPath: \ConferenceRouteState.memberSelectionFactory)

class ConferenceRouter: NSObject {
    override init() {
        super.init()
    }
    // MARK: - private property.
    private var cancellableSet = Set<AnyCancellable>()
    private weak var navigationController: UINavigationController?
    private weak var rootViewController: UIViewController?
    private weak var navigationControllerDelegate: UINavigationControllerDelegate?
    private let store: Store<ConferenceRouteState, Void> = {
        let store = Store.init(initialState: ConferenceRouteState(), reducers: [routeReducer])
        #if DEBUG
        store.register(interceptor: PrintRouteInterceptor())
        #endif
        return store
    }()
}

extension ConferenceRouter: Route {
    
    func initializeRoute(viewController: UIViewController, rootRoute: ConferenceRoute) {
        guard self.rootViewController == nil else { return }
        self.rootViewController = viewController
        if let nav = viewController.navigationController {
            self.navigationController = nav
            if nav.delegate == nil {
                nav.delegate = self
            } else {
                self.navigationControllerDelegate = nav.delegate
                nav.delegate = self
            }
        } else {
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.navigationController = navigationController
        }
        store.dispatch(action: ConferenceNavigationAction.navigate(payload: ConferenceNavigation.presented(route: rootRoute)))
        let navigationPublisher = store.select(currentRouteActionSelector)
        subscribe(to: navigationPublisher)
    }
    
    func pushTo(route: ConferenceRoute) {
        store.dispatch(action: ConferenceNavigationAction.navigate(payload: .push(route: route)))
    }
    
    func present(route: ConferenceRoute) {
        store.dispatch(action: ConferenceNavigationAction.navigate(payload: .present(route: route)))
    }
    
    func dismiss(animated: Bool) {
        guard let viewController = self.navigationController?.topViewController ?? self.navigationController else { return }
        if let presentedViewController = viewController.presentedViewController {
            presentedViewController.dismiss(animated: animated) {
                [weak self] in
                guard let self = self else { return }
                if let rootVC = self.rootViewController {
                    let viewRoute = ConferenceRoute.init(viewController: rootVC)
                    self.store.dispatch(action: ConferenceNavigationAction.navigate(payload: ConferenceNavigation.presented(route: viewRoute)))
                }
            }
        }
    }
    
    func pop() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func popTo(route: ConferenceRoute) {
        guard let viewControllers = self.navigationController?.viewControllers else { return }
        if let targetVC = viewControllers.first(where: { viewController in
            let iterateRoute = ConferenceRoute(viewController: viewController)
            return iterateRoute == route
        }) {
            self.navigationController?.popToViewController(targetVC, animated: false)
        }
    }
    
    func pop(route: ConferenceRoute) {
        guard var viewControllers = self.navigationController?.viewControllers else { return }
        if let index = viewControllers.firstIndex(where: { viewController in
            let iterateRoute = ConferenceRoute(viewController: viewController)
            return iterateRoute == route
        }) {
            viewControllers.remove(at: index)
            self.navigationController?.viewControllers = viewControllers
        }
    }
    
    func uninitialize() {
        if let delegate = self.navigationControllerDelegate {
            self.navigationController?.delegate = delegate
        }
    }
    
    func showContactView(delegate: ContactViewSelectDelegate, participants: ConferenceParticipants) {
        guard let factory = store.selectCurrent(memberSelectFactorySelector) else { return }
        let selectParams = MemberSelectParams(participants: participants, delegate: delegate, factory: factory)
        store.dispatch(action: ConferenceNavigationAction.navigate(payload: .push(route: .selectMember(memberSelectParams: selectParams))))
    }
    
    func dispatch(action: Action) {
        store.dispatch(action: action)
    }
}

extension ConferenceRouter {
    var viewController: UIViewController? {
        return navigationController ?? rootViewController
    }
}

extension ConferenceRouter {
    private func subscribe(to navigationPublisher: AnyPublisher<ConferenceNavigation, Never>) {
        navigationPublisher
            .receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] action in
                guard let self = self else { return }
                self.respond(to: action)
            }
            .store(in: &cancellableSet)
    }
    
    private func respond(to action: ConferenceNavigation) {
        switch action {
            case let .present(route: route):
                present(viewRoute: route)
            case let .push(route: route):
                push(viewRoute: route)
            case .presented:
                break
        }
    }
    
    private func present(viewRoute: ConferenceRoute) {
        guard let viewController = self.navigationController?.topViewController ?? self.navigationController else { return }
        if viewController.presentedViewController != nil {
            self.dismiss(animated: false)
        }
        var animated: Bool = true
        if case .invitation = viewRoute {
            animated = false
        }
        viewController.present(viewRoute.viewController, animated: animated) { [weak self] in
            guard let self = self else { return }
            self.store.dispatch(action: ConferenceNavigationAction.navigate(payload: ConferenceNavigation.presented(route: viewRoute)))
        }
    }
    
    private func push(viewRoute: ConferenceRoute) {
        guard let navigationController = self.navigationController else { return }
        navigationController.pushViewController(viewRoute.viewController, animated: true)
    }
}

extension ConferenceRouter {
    func toggleNavigationBar(for view: ConferenceRoute, animated: Bool, navigationController: UINavigationController) {
        if view.hideNavigationBar() {
            hideNavigationBar(navigationController: navigationController, animated: animated)
        }
        else {
            showNavigationBar(navigationController: navigationController, animated: animated)
        }
    }
    
    func hideNavigationBar(navigationController: UINavigationController, animated: Bool) {
        if animated {
            navigationController.transitionCoordinator?.animate(alongsideTransition: {
                context in
                navigationController.setNavigationBarHidden(true, animated: true)
            })
        }
        else {
            navigationController.setNavigationBarHidden(true, animated: false)
        }
    }
    
    func showNavigationBar(navigationController: UINavigationController, animated: Bool) {
        if navigationController.isNavigationBarHidden {
            if animated {
                navigationController.transitionCoordinator?.animate(alongsideTransition: {
                    context in
                    navigationController.setNavigationBarHidden(false, animated: true)
                })
            }
            else {
                navigationController.setNavigationBarHidden(false, animated: false)
            }
        }
    }
}

extension ConferenceRouter: UINavigationControllerDelegate {
    /// Animate the navigation bar display with view controller transition.
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool) {
            let destRoute = ConferenceRoute.init(viewController: viewController)
            guard destRoute != .none else { return }
            toggleNavigationBar(for: destRoute, animated: animated, navigationController: navigationController)
        }
    
    /// Trigger a `ConferenceNavigationAction` event according to the destination view type.
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool) {
            let destRoute = ConferenceRoute.init(viewController: viewController)
            guard destRoute != .none else { return }
            self.store.dispatch(action: ConferenceNavigationAction.navigate(payload: ConferenceNavigation.presented(route: destRoute)))
        }
}
