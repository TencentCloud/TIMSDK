//
//  GroupLoadingView.swift
//  TUICallKit
//
//  Created by noah on 2023/11/28.
//

import Foundation

let kGroupLoadingViewDotSize: CGFloat = 6.scaleWidth()

class GroupLoadingView: UIView {
    
    let dotSpacing: CGFloat = 8.scaleWidth()
    let animationDuration: TimeInterval = 0.5
    
    private let dotLeft: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = kGroupLoadingViewDotSize / 2
        view.alpha = 0.8
        return view
    }()
    
    private let dotCenter: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = kGroupLoadingViewDotSize / 2
        view.alpha = 0.5
        return view
    }()
    
    private let dotRight: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = kGroupLoadingViewDotSize / 2
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
        dotLeft.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.centerX.equalTo(dotCenter).offset(-(dotSpacing + kGroupLoadingViewDotSize))
            make.width.height.equalTo(kGroupLoadingViewDotSize)
        }
        dotCenter.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.width.height.equalTo(kGroupLoadingViewDotSize)
        }
        dotRight.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.centerX.equalTo(dotCenter).offset(dotSpacing + kGroupLoadingViewDotSize)
            make.width.height.equalTo(kGroupLoadingViewDotSize)
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
