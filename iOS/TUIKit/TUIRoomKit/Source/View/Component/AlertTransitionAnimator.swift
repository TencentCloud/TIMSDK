//
//  AlertTransitionAnimator.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/4/6.
//

import Foundation

class AlertTransitionAnimator : NSObject {
    enum AlertTransitionStyle {
        case present
        case dismiss
    }
    enum AlertTransitionPosition {
        case bottom
        case right
    }
    var duration = 0.5
    var alertTransitionStyle: AlertTransitionStyle = .present
    var alertTransitionPosition: AlertTransitionPosition = .bottom
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension AlertTransitionAnimator {
    private func presentTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromController = transitionContext.viewController(forKey: .from), let toController = transitionContext.viewController(forKey: .to)
        else { return }
        guard let fromView = fromController.view, let toView = toController.view else { return }
        let contentView = transitionContext.containerView
        fromView.tintAdjustmentMode = .normal
        fromView.isUserInteractionEnabled = false
        toView.isUserInteractionEnabled = false
        contentView.addSubview(toView)
        switch alertTransitionPosition {
        case .bottom:
            toView.frame = CGRect(x: 0, y: contentView.bounds.size.height, width: contentView.bounds.size.width, height:
                                    contentView.bounds.size.height)
        case .right:
            toView.frame = CGRect(x: contentView.bounds.size.width, y: 0, width: contentView.bounds.size.width/2, height:
                                    contentView.bounds.size.height)
        }
        UIView.animate(withDuration: duration, animations: { [weak self] in
            guard let self = self else { return }
            switch self.alertTransitionPosition {
            case .bottom:
                toView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.size.width, height: contentView.bounds.size.height)
            case .right:
                toView.frame = CGRect(x: 0, y: 0, width: contentView.bounds.size.width, height: contentView.bounds.size.height)
            }
        }) { (finish) in
            fromView.isUserInteractionEnabled = true
            toView.isUserInteractionEnabled = true
            transitionContext.completeTransition(true)
        }
    }
    
    private func dismissTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromController = transitionContext.viewController(forKey: .from), let toController = transitionContext.viewController(forKey: .to)
        else { return }
        guard let fromView = fromController.view, let toView = toController.view else { return }
        fromView.isUserInteractionEnabled = false
        toView.isUserInteractionEnabled = false
        let contentView = transitionContext.containerView
        UIView.animate(withDuration: duration, animations: { [weak self] in
            guard let self = self else { return }
            switch self.alertTransitionPosition {
            case .bottom:
                fromView.frame = CGRect(x: 0, y: contentView.bounds.size.height, width: contentView.bounds.size.width, height:
                                            contentView.bounds.size.height)
            case .right:
                fromView.frame = CGRect(x: contentView.bounds.size.width, y: 0, width: contentView.bounds.size.width, height:
                                            contentView.bounds.size.height)
            }
        }) { (finish) in
            fromView.removeFromSuperview()
            toView.isUserInteractionEnabled = true
            transitionContext.completeTransition(true)
        }
    }
}

extension AlertTransitionAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch alertTransitionStyle {
        case .present:
            presentTransition(transitionContext: transitionContext)
        case .dismiss:
            dismissTransition(transitionContext: transitionContext)
        }
    }
}
