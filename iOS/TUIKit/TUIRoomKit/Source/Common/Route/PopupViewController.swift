//
//  PopupViewController.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/26.
//

import UIKit
import Factory

class PopupViewController: UIViewController {
    
    let contentView: UIView
    
    private let visualEffectView: UIView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: blurEffect)
        view.frame = UIScreen.main.bounds
        view.alpha = 0
        return view
    }()
    
    public init(contentView: UIView) {
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        constructViewHierarchy()
        activateConstraints()
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func constructViewHierarchy() {
        view.addSubview(contentView)
    }
    
    func activateConstraints() {
        contentView.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let point = touch.location(in: contentView)
        guard !contentView.layer.contains(point) else { return }
        route.dismiss(animated: true)
    }
    
    // MARK: - private property.
    @Injected(\.navigation) private var route: Route
}

extension PopupViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) ->
    UIViewControllerAnimatedTransitioning? {
        let transitionAnimator = AlertTransitionAnimator()
        transitionAnimator.alertTransitionStyle = .present
        if interfaceOrientation.isPortrait {
            transitionAnimator.alertTransitionPosition = .bottom
        } else {
            transitionAnimator.alertTransitionPosition = .right
        }
        source.view.addSubview(visualEffectView)
        UIView.animate(withDuration: transitionAnimator.duration) { [weak self] in
            guard let self = self else { return }
            self.visualEffectView.alpha = 1
        }
        return transitionAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transitionAnimator = AlertTransitionAnimator()
        transitionAnimator.alertTransitionStyle = .dismiss
        if interfaceOrientation.isPortrait {
            transitionAnimator.alertTransitionPosition = .bottom
        } else {
            transitionAnimator.alertTransitionPosition = .right
        }
        UIView.animate(withDuration: transitionAnimator.duration) { [weak self] in
            guard let self = self else { return }
            self.visualEffectView.alpha = 0
        } completion: { [weak self] finished in
            guard let self = self else { return }
            if finished {
                self.visualEffectView.removeFromSuperview()
            }
        }
        return transitionAnimator
    }
}
