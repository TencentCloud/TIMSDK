//
//  ConferenceMainViewController.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/3/6.
//

import UIKit

@objcMembers public class ConferenceMainViewController: UIViewController {
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
    
    public func quickStartConference(conferenceId: String) {
        viewModel.quickStartConference(conferenceId: conferenceId)
    }
    
    public func joinConference(conferenceId: String) {
        viewModel.joinConference(conferenceId: conferenceId)
    }
    
    public func setConferenceParams(params: ConferenceParams) {
        viewModel.setConferenceParams(params: params)
    }
    
    public func setConferenceObserver(observer: ConferenceObserver) {
        viewModel.setConferenceObserver(observer: observer)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
