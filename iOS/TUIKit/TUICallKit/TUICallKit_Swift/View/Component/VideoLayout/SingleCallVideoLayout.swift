//
//  SingleCallVideoLayout.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

import UIKit
import RTCCommon
import RTCRoomEngine

private let kCallKitSingleSmallVideoViewWidth = 100.0
private let kCallKitSingleSmallVideoViewFrame = CGRect(x: ScreenSize.width - kCallKitSingleSmallVideoViewWidth,
                                                       y: StatusBar_Height + 40,
                                                       width: kCallKitSingleSmallVideoViewWidth,
                                                       height: kCallKitSingleSmallVideoViewWidth / 9.0 * 16.0)
private let kCallKitSingleLargeVideoViewFrame = CGRect(x: 0, y: 0, width: ScreenSize.width, height: ScreenSize.height)

class SingleCallVideoLayout: UIView, GestureViewDelegate {
    private let callStatusObserver = Observer()
    private let isVirtualBackgroundOpenedObserver = Observer()

    private var isViewReady: Bool = false
    private var selfUserIsLarge = true
    
    private var selfVideoView: VideoView {
        guard let videoView = VideoFactory.shared.createVideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: false) else {
            Logger.error("SingleCallVideoLayout->selfVideoView, create video view failed")
            return VideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: false)
        }
        return videoView
    }
    private var remoteVideoView: VideoView {
        if let remoteUser = CallManager.shared.userState.remoteUserList.value.first {
            if let videoView = VideoFactory.shared.createVideoView(user: remoteUser, isShowFloatWindow: false) {
                return videoView
            }
        }
        Logger.error("SingleCallVideoLayout->remoteVideoView, create video view failed")
        return VideoView(user: User(), isShowFloatWindow: false)
    }
    
    private let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 6.0
        if let user = CallManager.shared.userState.remoteUserList.value.first {
            userHeadImageView.sd_setImage(with: URL(string: user.avatar.value), placeholderImage: CallKitBundle.getBundleImage(name: "default_user_icon"))
        }
        return userHeadImageView
    }()
    private let userNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.textColor = UIColor(hex: "#D5E0F2")
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        if let user = CallManager.shared.userState.remoteUserList.value.first {
            userNameLabel.text = UserManager.getUserDisplayName(user: user)
        }
        return userNameLabel
    }()
        
    // MARK: Init, deinit
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateView()
        registerObserver()
    }
    
    deinit {
        unregisterobserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        if CallManager.shared.callState.mediaType.value == .video {
            addSubview(selfVideoView)
        }
        addSubview(remoteVideoView)
        
        addSubview(userHeadImageView)
        addSubview(userNameLabel)
    }
    
    private func activateConstraints() {
        userHeadImageView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = userHeadImageView.superview {
            NSLayoutConstraint.activate([
                userHeadImageView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                userHeadImageView.centerYAnchor.constraint(equalTo: superview.centerYAnchor, constant: -100.scale375Width()),
                userHeadImageView.widthAnchor.constraint(equalToConstant: 100.scale375Width()),
                userHeadImageView.heightAnchor.constraint(equalToConstant: 100.scale375Width())
            ])
        }

        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = userNameLabel.superview {
            NSLayoutConstraint.activate([
                userNameLabel.topAnchor.constraint(equalTo: userHeadImageView.bottomAnchor, constant: 10.scale375Height()),
                userNameLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                userNameLabel.widthAnchor.constraint(equalTo: superview.widthAnchor),
                userNameLabel.heightAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        if CallManager.shared.callState.mediaType.value == .video {
            selfVideoView.frame = kCallKitSingleLargeVideoViewFrame
            remoteVideoView.frame = kCallKitSingleSmallVideoViewFrame
        } else if CallManager.shared.callState.mediaType.value == .audio {
            remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
            if let superview = remoteVideoView.superview {
                NSLayoutConstraint.activate([
                    remoteVideoView.topAnchor.constraint(equalTo: superview.topAnchor),
                    remoteVideoView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                    remoteVideoView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                    remoteVideoView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
                ])
            }
        }
    }
    
    private func bindInteraction() {
        if CallManager.shared.callState.mediaType.value == .video {
            selfVideoView.delegate = self
        }
        
        remoteVideoView.delegate = self
    }

    // MARK: Observer
    private func registerObserver() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == .none { return }
            updateView()
            switchPreview()
        }
        
        CallManager.shared.viewState.isVirtualBackgroundOpened.addObserver(isVirtualBackgroundOpenedObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue && !self.selfUserIsLarge {
                self.switchPreview()
            }
        }
    }
    
    private func unregisterobserver() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
        CallManager.shared.viewState.isVirtualBackgroundOpened.removeObserver(isVirtualBackgroundOpenedObserver)
    }

    // MARK: Config View
    private func updateView() {
        updateUserInfo()
        
        if CallManager.shared.callState.mediaType.value == .audio {
            remoteVideoView.isHidden = false
            return
        }
        
        if CallManager.shared.userState.selfUser.videoAvailable.value == false && CallManager.shared.mediaState.isCameraOpened.value == true {
            CallManager.shared.openCamera(videoView: selfVideoView.getVideoView()) { } fail: { code, message in }
        }

        if  CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            remoteVideoView.isHidden = true
            selfVideoView.isHidden = false
        }
        
        if  CallManager.shared.userState.selfUser.callStatus.value == .accept {
            remoteVideoView.isHidden = false
            selfVideoView.isHidden = false

           if let remoteUser = CallManager.shared.userState.remoteUserList.value.first {
                CallManager.shared.startRemoteView(user: remoteUser, videoView: remoteVideoView.getVideoView())
            }
        }
    }
    
    private func switchPreview() {
        guard CallManager.shared.callState.mediaType.value == .video else { return }
        if selfUserIsLarge {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.selfVideoView.frame = kCallKitSingleSmallVideoViewFrame
                self.remoteVideoView.frame = kCallKitSingleLargeVideoViewFrame
            } completion: { finished in
                self.sendSubviewToBack(self.remoteVideoView)
            }
            selfUserIsLarge = false
        } else {
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.selfVideoView.frame = kCallKitSingleLargeVideoViewFrame
                self.remoteVideoView.frame = kCallKitSingleSmallVideoViewFrame
            } completion: { finished in
                self.sendSubviewToBack(self.selfVideoView)
            }
            selfUserIsLarge = true
        }
    }
    
    private func updateUserInfo() {
        if CallManager.shared.userState.selfUser.callStatus.value == .accept && CallManager.shared.callState.mediaType.value == .video {
            userHeadImageView.isHidden = true
            userNameLabel.isHidden = true
        }
    }
    
    // MARK: Gesture Action
    @objc func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        if  tapGesture.view?.frame.size.width == CGFloat(kCallKitSingleSmallVideoViewWidth) {
            switchPreview()
            return
        }
        
        if CallManager.shared.userState.selfUser.callStatus.value == .accept {
            CallManager.shared.viewState.isScreenCleaned.value = !CallManager.shared.viewState.isScreenCleaned.value
        }
    }
    
    @objc func panGestureAction(panGesture: UIPanGestureRecognizer) {
        if panGesture.view?.frame.size.width != CGFloat(kCallKitSingleSmallVideoViewWidth) { return }
        
        let smallView = panGesture.view?.superview
        if panGesture.state == .changed {
            let translation = panGesture.translation(in: self)
            let newCenterX = translation.x + (smallView?.center.x ?? 0.0)
            let newCenterY = translation.y + (smallView?.center.y ?? 0.0)
            
            if newCenterX < ((smallView?.bounds.size.width ?? 0.0) / 2.0) ||
                newCenterX > self.bounds.size.width - (smallView?.bounds.size.width ?? 0.0) / 2.0 {
                return
            }
            
            if newCenterY < ((smallView?.bounds.size.height ?? 0.0) / 2.0) ||
                newCenterY > self.bounds.size.height - (smallView?.bounds.size.height ?? 0.0) / 2.0 {
                return
            }
            
            UIView.animate(withDuration: 0.1) {
                smallView?.center = CGPoint(x: newCenterX, y: newCenterY)
            }
            panGesture.setTranslation(CGPointZero, in: self)
        }
    }
}
