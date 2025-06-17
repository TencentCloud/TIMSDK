//
//  MultiCallLoadingView.swift
//  TUICallKit
//
//  Created by noah on 2023/11/28.
//

import Foundation

let kMultiCallLoadingViewDotSize: CGFloat = 6.scale375Width()

class MultiCallLoadingView: UIView {
    
    let dotSpacing: CGFloat = 8.scale375Width()
    let animationDuration: TimeInterval = 0.5
    
    private let dotLeft: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = kMultiCallLoadingViewDotSize / 2
        view.alpha = 0.8
        return view
    }()
    
    private let dotCenter: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = kMultiCallLoadingViewDotSize / 2
        view.alpha = 0.5
        return view
    }()
    
    private let dotRight: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = kMultiCallLoadingViewDotSize / 2
        view.alpha = 0.2
        return view
    }()
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    private func constructViewHierarchy() {
        addSubview(dotLeft)
        addSubview(dotCenter)
        addSubview(dotRight)
    }
    
    private func activateConstraints() {
        dotLeft.translatesAutoresizingMaskIntoConstraints = false
        if let superview = dotLeft.superview {
            NSLayoutConstraint.activate([
                dotLeft.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                dotLeft.centerXAnchor.constraint(equalTo: dotCenter.centerXAnchor, constant: -(dotSpacing + kMultiCallLoadingViewDotSize)),
                dotLeft.widthAnchor.constraint(equalToConstant: kMultiCallLoadingViewDotSize),
                dotLeft.heightAnchor.constraint(equalToConstant: kMultiCallLoadingViewDotSize)
            ])
        }

        dotCenter.translatesAutoresizingMaskIntoConstraints = false
        if let superview = dotCenter.superview {
            NSLayoutConstraint.activate([
                dotCenter.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                dotCenter.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                dotCenter.widthAnchor.constraint(equalToConstant: kMultiCallLoadingViewDotSize),
                dotCenter.heightAnchor.constraint(equalToConstant: kMultiCallLoadingViewDotSize)
            ])
        }

        dotRight.translatesAutoresizingMaskIntoConstraints = false
        if let superview = dotRight.superview {
            NSLayoutConstraint.activate([
                dotRight.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                dotRight.centerXAnchor.constraint(equalTo: dotCenter.centerXAnchor, constant: dotSpacing + kMultiCallLoadingViewDotSize),
                dotRight.widthAnchor.constraint(equalToConstant: kMultiCallLoadingViewDotSize),
                dotRight.heightAnchor.constraint(equalToConstant: kMultiCallLoadingViewDotSize)
            ])
        }
    }
    
    func resetDotsAlpha() {
        dotLeft.alpha = 0.8
        dotCenter.alpha = 0.5
        dotRight.alpha = 0.2
    }
    
    // MARK: UI Animation
    private var isAnimation: Bool = false
    func startAnimating() {
        if isAnimation {
            return
        } else {
            isAnimation = true
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.dotLeft.alpha = 0.2
            self.dotCenter.alpha = 0.8
            self.dotRight.alpha = 0.5
        } completion: { finished in
            if finished {
                self.startSecondAnimation()
            }
        }
    }
    
    private func startSecondAnimation() {
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut ], animations: {
            self.dotLeft.alpha = 0.2
            self.dotCenter.alpha = 0.5
            self.dotRight.alpha = 0.8
        }, completion: { finished in
            if finished {
                self.startThirdAnimation()
            }
        })
    }
    
    private func startThirdAnimation() {
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut ], animations: {
            self.dotRight.alpha = 0.5
        }, completion: { finished in
            if finished {
                self.startFourthAnimation()
            }
        })
    }
    
    private func startFourthAnimation() {
        UIView.animate(withDuration: animationDuration, delay: 0, options: [.curveEaseInOut ], animations: {
            self.dotLeft.alpha = 0.8
            self.dotCenter.alpha = 0.5
            self.dotRight.alpha = 0.2
        }, completion: { finished in
            if finished {
                self.isAnimation = false
                self.startAnimating()
            }
        })
    }
    
    func stopAnimating() {
        dotLeft.layer.removeAllAnimations()
        dotCenter.layer.removeAllAnimations()
        dotRight.layer.removeAllAnimations()
        resetDotsAlpha()
        isAnimation = false
    }
}
