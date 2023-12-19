//
//  FloatingWindow.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import UIKit
import TUICore

class FloatingWindowSignalView: UIView {
    
    let viewModel = FloatingWindowViewModel()
    weak var delegate: FloatingWindowViewDelegate?
    
    let selfCallStatusObserver = Observer()
    let remoteUserListObserver = Observer()
    let callTimeObserver = Observer()
    
    let kFloatingWindowVideoViewRect = CGRect(x: 0,
                                              y: 0,
                                              width: kMicroVideoViewWidth - 16.scaleWidth(),
                                              height: kMicroVideoViewHeight - 16.scaleWidth())
    
    var localPreView: VideoView {
        if VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: viewModel.selfUser.value.id.value, frame: CGRect.zero)
        }
        VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value]?.videoView.isUserInteractionEnabled = false
        return VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value]?.videoView ?? VideoView(frame: CGRect.zero)
    }
    
    var remotePreView: VideoView {
        guard let remoteUser = viewModel.remoteUserList.value.first else { return VideoView(frame: CGRect.zero) }
        if VideoFactory.instance.viewMap[remoteUser.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: remoteUser.id.value, frame: CGRect.zero)
        }
        VideoFactory.instance.viewMap[remoteUser.id.value]?.videoView.isUserInteractionEnabled = false
        return VideoFactory.instance.viewMap[remoteUser.id.value]?.videoView ?? VideoView(frame: CGRect.zero)
    }
    
    let avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 8.scaleWidth()
        avatarImageView.isUserInteractionEnabled = false
        return avatarImageView
    }()
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                       defaultHex:  "#FFFFFF")
        containerView.layer.cornerRadius = 12.scaleWidth()
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    let audioContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                       defaultHex:  "#FFFFFF")
        return containerView
    }()
    
    let shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                    defaultHex:  "#FFFFFF")
        shadowView.layer.shadowColor = UIColor.t_colorWithHexString(color: "353941").cgColor
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.cornerRadius = 12.scaleWidth()
        shadowView.layer.shadowRadius = 4.scaleWidth()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        return shadowView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        if let image = TUICallKitCommon.getBundleImage(name: "icon_float_dialing") {
            imageView.image = image
        }
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    let audioDescribeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor.t_colorWithHexString(color: "#12B969")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        describeLabel.text = TUICallKitLocalize(key: "TUICallKit.FloatingWindow.waitAccept") ?? ""
        return describeLabel
    }()
    
    let videoDescribeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor.t_colorWithHexString(color: "#FFFFFF")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        describeLabel.text = TUICallKitLocalize(key: "TUICallKit.FloatingWindow.waitAccept") ?? ""
        return describeLabel
    }()
    
    lazy var timerLabel: UILabel = {
        let timerLabel = UILabel()
        timerLabel.font = UIFont.systemFont(ofSize: 12.0)
        timerLabel.textColor = UIColor.t_colorWithHexString(color: "#12B969")
        timerLabel.textAlignment = .center
        timerLabel.isUserInteractionEnabled = false
        timerLabel.text = viewModel.getCallTimeString()
        return timerLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserverState()
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.selfCallStatus.removeObserver(callTimeObserver)
    }
    
    func constructViewHierarchy() {
        addSubview(shadowView)
        addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(audioContainerView)
        audioContainerView.addSubview(imageView)
        audioContainerView.addSubview(audioDescribeLabel)
        audioContainerView.addSubview(timerLabel)
        containerView.addSubview(videoDescribeLabel)
    }
    
    func activateConstraints() {
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.top.equalTo(8.scaleWidth())
        }
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(45.scaleWidth())
        }
        audioContainerView.snp.makeConstraints { make in
            make.top.centerX.equalTo(containerView)
            make.width.height.equalTo(72.scaleWidth())
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(audioContainerView).offset(8.scaleWidth())
            make.centerX.equalTo(audioContainerView)
            make.width.height.equalTo(36.scaleWidth())
        }
        audioDescribeLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(audioContainerView)
            make.top.equalTo(imageView.snp.bottom).offset(4.scaleWidth())
            make.height.equalTo(20.scaleWidth())
        }
        timerLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(audioContainerView)
            make.top.equalTo(imageView.snp.bottom).offset(4.scaleWidth())
            make.height.equalTo(20.scaleWidth())
        }
        videoDescribeLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(containerView)
            make.bottom.equalTo(containerView).offset(-8.scaleWidth())
            make.height.equalTo(20.scaleWidth())
        }
    }
    
    func bindInteraction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(tapGesture: )))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(panGesture: )))
        self.addGestureRecognizer(tap)
        pan.require(toFail: tap)
        self.addGestureRecognizer(pan)
    }
    
    func clearSubview() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    // MARK: Action Event
    @objc func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("tapGestureAction")))) != nil) {
            self.delegate?.tapGestureAction(tapGesture: tapGesture)
        }
    }
    
    @objc func panGestureAction(panGesture: UIPanGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("panGestureAction")))) != nil) {
            self.delegate?.panGestureAction(panGesture: panGesture)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserverState() {
        registerCallStatusObserver()
        registerCallTimeObserver()
    }
    
    func registerCallStatusObserver() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        })
    }
    
    func registerCallTimeObserver() {
        viewModel.callTime.addObserver(callTimeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            DispatchCallKitMainAsyncSafe {
                self.timerLabel.text = self.viewModel.getCallTimeString()
            }
        })
    }
    
    func userVideoAvailableChange() {
        if viewModel.remoteUserList.value.first != nil {
            viewModel.remoteUserList.value.first?.videoAvailable.addObserver(remoteUserListObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateUI()
            })
        }
    }
    
    // MARK: Update UI
    func updateUI() {
        cleanView()
        
        if viewModel.mediaType.value == .audio {
            updateSingleAudioUI()
        } else if viewModel.mediaType.value == .video {
            updateSingleVideoUI()
        }
    }
    
    func updateSingleAudioUI() {
        containerView.backgroundColor = UIColor.t_colorWithHexString(color: "FFFFFF")
        
        if viewModel.selfCallStatus.value == .waiting {
            setSingleAudioWaitingUI()
        } else if viewModel.selfCallStatus.value == .accept {
            setSingleAudioAcceptUI()
        }
    }
    
    func updateSingleVideoUI() {
        containerView.backgroundColor = UIColor.t_colorWithHexString(color: "303132")
        
        if viewModel.selfCallStatus.value == .waiting {
            setSingleVideoWaitingUI()
        } else if viewModel.selfCallStatus.value == .accept {
            guard let remoteUser = viewModel.remoteUserList.value.first else { return }
            
            if remoteUser.videoAvailable.value == true {
                setSingleVideoAcceptUI()
            } else {
                setSingleVideoAcceptWithUnavailableUI()
            }
        }
        
        userVideoAvailableChange()
    }
    
    func setSingleAudioWaitingUI() {
        audioContainerView.isHidden = false
        imageView.isHidden = false
        audioDescribeLabel.isHidden = false
    }
    
    func setSingleAudioAcceptUI() {
        audioContainerView.isHidden = false
        imageView.isHidden = false
        timerLabel.isHidden = false
    }
    
    func setSingleVideoWaitingUI() {
        localPreView.frame = kFloatingWindowVideoViewRect
        videoDescribeLabel.isHidden = false
        containerView.addSubview(localPreView)
        containerView.bringSubviewToFront(videoDescribeLabel)
    }
    
    func setSingleVideoAcceptUI() {
        remotePreView.frame = kFloatingWindowVideoViewRect
        remotePreView.isHidden = false
        containerView.addSubview(remotePreView)
        guard let remoteUser = self.viewModel.remoteUserList.value.first else { return }
        viewModel.startRemoteView(user: remoteUser, videoView: remotePreView)
    }
    
    func setSingleVideoAcceptWithUnavailableUI() {
        avatarImageView.isHidden = false
        remotePreView.isHidden = true
        containerView.bringSubviewToFront(avatarImageView)
        
        guard let remoteUser = viewModel.remoteUserList.value.first else { return }
        let userIcon: UIImage? = TUICallKitCommon.getBundleImage(name: "default_user_icon")
        
        if remoteUser.avatar.value == "" {
            guard let image = userIcon else { return }
            avatarImageView.image = image
        } else {
            avatarImageView.sd_setImage(with: URL(string: remoteUser.avatar.value), placeholderImage: userIcon)
        }
    }
    
    func cleanView() {
        avatarImageView.isHidden = true
        audioContainerView.isHidden = true
        imageView.isHidden = true
        audioDescribeLabel.isHidden = true
        timerLabel.isHidden = true
        videoDescribeLabel.isHidden = true
    }
    
}
