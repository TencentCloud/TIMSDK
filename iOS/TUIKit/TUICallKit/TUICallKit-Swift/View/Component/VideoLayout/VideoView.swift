//
//  VideoView.swift
//  TUICallKit
//
//  Created by : on 2023/2/14.
//

import Foundation
import TUICallEngine

@objc protocol VideoViewDelegate: NSObjectProtocol {
    @objc optional func tapGestureAction(tapGesture: UITapGestureRecognizer)
    @objc optional func panGestureAction(panGesture: UIPanGestureRecognizer)
}

class VideoView: TUIVideoView {
    weak var delegate: VideoViewDelegate?
    
    let volumeProgress: UIProgressView = {
        let volumeProgress = UIProgressView(progressViewStyle: .default)
        volumeProgress.backgroundColor = UIColor.clear
        return volumeProgress
    }()
    
    let gestureView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.t_colorWithHexString(color: "#55534F")

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }

    func constructViewHierarchy() {
        addSubview(gestureView)
        addSubview(volumeProgress)
    }

    func activateConstraints() {
        
        gestureView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        volumeProgress.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(4)
        }
    }

    func bindInteraction() {
        gestureView.backgroundColor = UIColor.clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(tapGesture: )))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGesture: )))
        gestureView.addGestureRecognizer(tap)
        pan.require(toFail: tap)
        gestureView.addGestureRecognizer(pan)
    }
    
    //MARK: Gesture Action
    @objc func tapGesture(tapGesture: UITapGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("tapGestureAction")))) != nil) {
            self.delegate?.tapGestureAction?(tapGesture: tapGesture)
        }
    }
    
    @objc func panGesture(panGesture: UIPanGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("panGestureAction")))) != nil) {
            self.delegate?.panGestureAction?(panGesture: panGesture)
        }
        
    }
    
}
