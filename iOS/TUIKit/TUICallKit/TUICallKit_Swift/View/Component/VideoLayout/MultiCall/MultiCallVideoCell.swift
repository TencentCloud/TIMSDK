//
//  Untitled.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/25.
//

import RTCCommon

class MultiCallVideoCell: UICollectionViewCell {
    private var user: User?
    private let callStatusObserver = Observer()
    
    private var videoView: VideoView {
        if let user = self.user {
            if let videoView =  VideoFactory.shared.createVideoView(user: user, isShowFloatWindow: false) {
                return videoView
            }
        }
        Logger.error("MultiCallVideoCell->videoView, create video view failed")
        return VideoView(user: User(), isShowFloatWindow: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == .none { return }
            self.setRender()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
    }
    
    // MARK: init cell data
    func initCell(user: User) {
        self.user = user
        setupView()
    }
    
    // MARK: UI Specification Processing
    private func setupView() {
        if CallManager.shared.userState.selfUser.callStatus.value == .none { return }
        contentView.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = videoView.superview {
            NSLayoutConstraint.activate([
                videoView.topAnchor.constraint(equalTo: superview.topAnchor),
                videoView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                videoView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                videoView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
        setRender()
    }
    
    private func setRender() {
        if user?.id.value == CallManager.shared.userState.selfUser.id.value {
            if (CallManager.shared.userState.selfUser.callStatus.value == .accept &&
                CallManager.shared.mediaState.isCameraOpened.value == true &&
                CallManager.shared.userState.selfUser.callRole.value == .called) ||
                (CallManager.shared.mediaState.isCameraOpened.value == true &&
                 CallManager.shared.userState.selfUser.callRole.value == .call) {
                CallManager.shared.openCamera(videoView: videoView.getVideoView()) { } fail: { code, message in }
            }
            return
        }
        CallManager.shared.startRemoteView(user: user ?? User(), videoView: videoView.getVideoView())
    }
}
