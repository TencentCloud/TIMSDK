//
//  FloatingWindowGroupView.swift
//  TUICallKit
//
//  Created by noah on 2023/11/21.
//

import Foundation
import UIKit
import TUICore

class FloatingWindowGroupView: UIView {
    
    let viewModel = FloatingWindowViewModel()
    weak var delegate: FloatingWindowViewDelegate?
    
    let selfCallStatusObserver = Observer()
    let remoteVideoAvailableObserver = Observer()
    let callTimeObserver = Observer()
    let currentSpeakUserObserver = Observer()
    let currentSpeakUserVideoAvailableObserver = Observer()
    
    var localPreView: VideoView {
        if VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: viewModel.selfUser.value.id.value, frame: CGRect.zero)
        }
        VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value]?.videoView.isUserInteractionEnabled = false
        return VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value]?.videoView ?? VideoView(frame: CGRect.zero)
    }
    
    var remotePreView: VideoView {
        let remoteUser = viewModel.currentSpeakUser.value
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
        shadowView.layer.shadowRadius = 4.scaleWidth()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.cornerRadius = 12.scaleWidth()
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
    
    lazy var timerLabel: UILabel = {
        let timerLabel = UILabel()
        timerLabel.font = UIFont.systemFont(ofSize: 12.0)
        timerLabel.textColor = UIColor.t_colorWithHexString(color: "#12B969")
        timerLabel.textAlignment = .center
        timerLabel.isUserInteractionEnabled = false
        timerLabel.text = viewModel.getCallTimeString()
        return timerLabel
    }()
    
    let groupNameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 12.0)
        nameLabel.textColor = UIColor.t_colorWithHexString(color: "#FFFFFF")
        nameLabel.textAlignment = .center
        nameLabel.isUserInteractionEnabled = false
        return nameLabel
    }()
    
    let groupStatusView: UIView = {
        let statusView = FloatingWindowGroupStatusView()
        return statusView
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
        viewModel.selfCallStatus.removeObserver(currentSpeakUserObserver)
        viewModel.currentSpeakUser.value.videoAvailable.removeObserver(currentSpeakUserVideoAvailableObserver)
        viewModel.selfCallStatus.removeObserver(callTimeObserver)
        for index in 0..<viewModel.remoteUserList.value.count {
            guard index < viewModel.remoteUserList.value.count else {
                break
            }
            viewModel.remoteUserList.value[index].videoAvailable.removeObserver(remoteVideoAvailableObserver)
        }
    }
    
    func constructViewHierarchy() {
        addSubview(shadowView)
        addSubview(containerView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(audioContainerView)
        audioContainerView.addSubview(imageView)
        audioContainerView.addSubview(audioDescribeLabel)
        audioContainerView.addSubview(timerLabel)
        containerView.addSubview(groupNameLabel)
        containerView.addSubview(groupStatusView)
    }
    
    func activateConstraints() {
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.top.equalTo(8.scaleWidth())
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
            make.top.equalTo(imageView.snp.bottom).offset(5.scaleWidth())
            make.height.equalTo(20.scaleWidth())
        }
        avatarImageView.snp.makeConstraints { make in
            make.top.centerX.width.equalToSuperview()
            make.bottom.equalTo(groupStatusView.snp.top)
        }
        groupNameLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(containerView)
            make.bottom.equalTo(groupStatusView.snp.top)
            make.height.equalTo(20.scaleWidth())
        }
        groupStatusView.snp.makeConstraints { make in
            make.centerX.width.equalTo(containerView)
            make.bottom.equalTo(containerView)
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
        registerCurrentSpeakUserObserver()
        registerCurrentSpeakUserVideoAvailableObserver()
        registerCallTimeObserver()
        registerUserVideoAvailableChange()
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
    
    func registerCurrentSpeakUserObserver() {
        viewModel.currentSpeakUser.addObserver(currentSpeakUserObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.viewModel.scene.value == .group {
                self.updateUI()
                self.groupNameLabel.text = newValue.nickname.value
                self.avatarImageView.sd_setImage(with: URL(string: newValue.avatar.value),
                                                 placeholderImage: TUICallKitCommon.getBundleImage(name: "default_user_icon"))
            }
        })
    }
    
    func registerCurrentSpeakUserVideoAvailableObserver() {
        viewModel.currentSpeakUser.value.videoAvailable.addObserver(currentSpeakUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.viewModel.scene.value == .group {
                self.updateUI()
                self.groupNameLabel.text = self.viewModel.currentSpeakUser.value.nickname.value
                self.avatarImageView.sd_setImage(with: URL(string: self.viewModel.currentSpeakUser.value.avatar.value),
                                                 placeholderImage: TUICallKitCommon.getBundleImage(name: "default_user_icon"))
            }
        })
    }
    
    func registerUserVideoAvailableChange() {
        for index in 0..<viewModel.remoteUserList.value.count {
            guard index < viewModel.remoteUserList.value.count else {
                break
            }
            viewModel.remoteUserList.value[index].videoAvailable.addObserver(remoteVideoAvailableObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                if (self.viewModel.currentSpeakUser.value.id.value == self.viewModel.remoteUserList.value[index].id.value) {
                    self.updateUI()
                }
            })
        }
    }
    
    // MARK: Update UI
    func updateUI() {
        cleanView()
        
        if viewModel.selfCallStatus.value == .waiting {
            setGroupWaitingUI()
        } else if viewModel.selfCallStatus.value == .accept {
            setGroupAcceptUI()
        }
    }
    
    func setGroupWaitingUI() {
        audioContainerView.isHidden = false
        imageView.isHidden = false
        audioDescribeLabel.isHidden = false
        groupStatusView.isHidden = false
    }
    
    func setGroupAcceptUI() {
        if viewModel.currentSpeakUser.value.id.value == viewModel.selfUser.value.id.value {
            setGroupLocalUI()
        } else if viewModel.currentSpeakUser.value.id.value.count > 0 {
            setGroupRemoteUI()
        } else {
            setGroupDefineUI()
        }
    }
    
    func setGroupDefineUI() {
        audioContainerView.isHidden = false
        imageView.isHidden = false
        timerLabel.isHidden = false
        groupStatusView.isHidden = false
    }
    
    func setGroupLocalUI() {
        groupStatusView.isHidden = false
        groupNameLabel.isHidden = false
        
        if TUICallState.instance.isCameraOpen.value {
            setGroupLocalVideoAvailableUI()
        } else {
            setGroupVideoNotAvailableUI()
        }
        
        containerView.bringSubviewToFront(groupNameLabel)
    }
    
    func setGroupRemoteUI() {
        groupStatusView.isHidden = false
        groupNameLabel.isHidden = false
        
        if viewModel.currentSpeakUser.value.videoAvailable.value {
            setGroupRemoteVideoAvailableUI()
        } else {
            setGroupVideoNotAvailableUI()
        }
        
        containerView.bringSubviewToFront(groupNameLabel)
    }
    
    func setGroupLocalVideoAvailableUI() {
        avatarImageView.isHidden = true
        containerView.addSubview(localPreView)
        localPreView.snp.remakeConstraints { make in
            make.edges.equalTo(avatarImageView)
        }
    }
    
    func setGroupRemoteVideoAvailableUI() {
        avatarImageView.isHidden = true
        containerView.addSubview(remotePreView)
        remotePreView.snp.makeConstraints { make in
            make.edges.equalTo(avatarImageView)
        }
        viewModel.startRemoteView(user: viewModel.currentSpeakUser.value, videoView: remotePreView)
    }
    
    func setGroupVideoNotAvailableUI() {
        avatarImageView.isHidden = false
        containerView.bringSubviewToFront(avatarImageView)
    }
    
    func cleanView() {
        avatarImageView.isHidden = true
        audioContainerView.isHidden = true
        imageView.isHidden = true
        audioDescribeLabel.isHidden = true
        timerLabel.isHidden = true
        groupStatusView.isHidden = true
        groupNameLabel.isHidden = true
    }
    
}
