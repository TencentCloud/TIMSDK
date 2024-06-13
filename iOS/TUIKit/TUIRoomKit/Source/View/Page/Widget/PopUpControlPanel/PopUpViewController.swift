//
//  PopUpViewController.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/12.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import UIKit

protocol PopUpViewModelFactory {
    func makeRootViewModel(viewType: PopUpViewType, height:CGFloat, backgroundColor: UIColor) -> PopUpViewModel
}

class PopUpViewController: UIViewController {
    let viewModel: PopUpViewModel
    var duration = 0.5
    var alertTransitionStyle: AlertTransitionAnimator.AlertTransitionStyle = .present
    var alertTransitionPosition: AlertTransitionAnimator.AlertTransitionPosition = .bottom
    var transitionAnimator: AlertTransitionAnimator?
    override var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    init(popUpViewModelFactory: PopUpViewModelFactory, viewType: PopUpViewType, height: CGFloat, backgroundColor: UIColor) {
        viewModel = popUpViewModelFactory.makeRootViewModel(viewType: viewType, height: height, backgroundColor: backgroundColor)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
        if isLandscape {
            self.alertTransitionPosition = .right
        } else {
            self.alertTransitionPosition = .bottom
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let rootView = PopUpView(viewModel: viewModel)
        rootView.responder = self
        view = rootView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension PopUpViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) ->
    UIViewControllerAnimatedTransitioning? {
        transitionAnimator = AlertTransitionAnimator()
        transitionAnimator?.alertTransitionStyle = .present
        transitionAnimator?.alertTransitionPosition = alertTransitionPosition
        transitionAnimator?.duration = duration
        return transitionAnimator
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator?.alertTransitionStyle = .dismiss
        return transitionAnimator
    }
}

extension PopUpViewController: PopUpViewResponder {
    func updateAlertTransitionPosition(position: AlertTransitionAnimator.AlertTransitionPosition) {
        transitionAnimator?.alertTransitionPosition = position
    }
}
