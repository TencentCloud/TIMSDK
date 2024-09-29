//
//  ConferenceMainViewController.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/3/6.
//

import UIKit
import Combine
import Factory
import TUICore

@objcMembers public class ConferenceMainViewController: UIViewController {
    private var cancellableSet = Set<AnyCancellable>()
    private var viewModel: ConferenceMainViewModel = ConferenceMainViewModel()
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    public override func loadView() {
        self.view = ConferenceMainView(viewModel: viewModel, viewFactory: viewModel)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        RoomRouter.shared.initializeNavigationController(rootViewController: self)
        RoomVideoFloatView.dismiss()
#if RTCube_APPSTORE
        let selector = NSSelectorFromString("showAlertUserLiveTips")
        if responds(to: selector) {
            perform(selector)
        }
#endif
        viewModel.onViewDidLoadAction()
        subscribeToast()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewStore.updateInternalCreation(isInternalCreation: false)
    }
    
    func quickStartConference() {
        viewModel.quickStartConference()
    }
    
    func joinConference() {
        viewModel.joinConference()
    }
    
    public func setStartConferenceParams(params: StartConferenceParams) {
        viewModel.setStartConferenceParams(params: params)
    }
    
    public func setJoinConferenceParams(params: JoinConferenceParams) {
        viewModel.setJoinConferenceParams(params: params)
    }
        
    var startConferenceParams: StartConferenceParams? {
        get {
            return viewModel.startConferenceParams
        }
    }
    
    var joinConferenceParams: JoinConferenceParams? {
        get {
            return viewModel.joinConferenceParams
        }
    }

    @Injected(\.conferenceMainViewStore) private var viewStore
    @Injected(\.conferenceStore) var operation: ConferenceStore
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension ConferenceMainViewController {
    private func subscribeToast() {
        operation.toastSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toast in
                guard let self = self else { return }
                var position = TUICSToastPositionBottom
                switch toast.position {
                case .center:
                    position = TUICSToastPositionCenter
                default:
                    break
                }
                self.view.makeToast(toast.message, duration: toast.duration, position: position)
            }
            .store(in: &cancellableSet)
    }
}
