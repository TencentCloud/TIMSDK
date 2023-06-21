//
//  AlertTransitionAnimator.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/4/6.
//

import Foundation

//转场管理器
class AlertTransitionAnimator : NSObject {
    enum AlertTransitionStyle {
        //弹出
        case present
        //消失
        case dismiss
    }
    enum AlertTransitionPosition {
        //弹出的位置
    case bottom
    case right
    }
    var duration = 0.5
    var alertTransitionStyle: AlertTransitionStyle = .present//动画的类型
    var alertTransitionPosition: AlertTransitionPosition = .bottom//动画弹出的位置
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
        toView.isUserInteractionEnabled = false//禁止页面产生用户交互
        contentView.addSubview(toView)//添加目标视图
        //根据弹出的位置计算动画开始前toview的frame
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
            //动画结束后恢复两个页面的用户交互能力
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
        toView.isUserInteractionEnabled = false//禁止两个页面产生用户交互
        let contentView = transitionContext.containerView
        //根据弹出的位置计算动画开始前toview的frame
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
            //动画结束后恢复页面的用户交互能力
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
