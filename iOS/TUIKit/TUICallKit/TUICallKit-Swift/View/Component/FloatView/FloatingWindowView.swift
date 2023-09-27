//
//  FloatingWindow.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import UIKit
import TUICore

private let kMicroWindowCornerRatio = 15.0
private let kMicroContainerViewOffset = 8.0

private let kCallKitSingleSmallVideoViewWidth = 100.0
private let kCallKitSingleSmallVideoViewFrame = CGRect(x: 5, y: 5, width: kCallKitSingleSmallVideoViewWidth - 10,
                                                       height: (kCallKitSingleSmallVideoViewWidth / 9.0 * 16.0) - 10 )

protocol FloatingWindowViewDelegate: NSObject {
    func tapGestureAction(tapGesture: UITapGestureRecognizer)
    func panGestureAction(panGesture: UIPanGestureRecognizer)
}

class FloatingWindowView: UIView {
    let viewModel = FloatingWindowViewModel()
    weak var delegate: FloatingWindowViewDelegate?
    
    let selfCallStatusObserver = Observer()
    let remoteUserListObserver = Observer()
    let callTimeObserver = Observer()
    
    var localPreView: VideoView {
        if VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: viewModel.selfUser.value.id.value, frame: CGRect.zero)
        }
        VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value]?.videoView.isUserInteractionEnabled = false
        return VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value]?.videoView ?? VideoView(frame: CGRect.zero)
    }
    
    var remotePreView: VideoView {
        guard let remoteUser = self.viewModel.remoteUserList.value.first else { return VideoView(frame: CGRect.zero) }
        if VideoFactory.instance.viewMap[remoteUser.id.value] == nil {
            let _ = VideoFactory.instance.createVideoView(userId: remoteUser.id.value, frame: CGRect.zero)
        }
        VideoFactory.instance.viewMap[remoteUser.id.value]?.videoView.isUserInteractionEnabled = false
        return  VideoFactory.instance.viewMap[remoteUser.id.value]?.videoView ?? VideoView(frame: CGRect.zero)
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
        containerView.backgroundColor = UIColor.t_colorWithHexString(color: "F2F2F2")
        containerView.layer.cornerRadius = 10.0
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = false

        return containerView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        if let image = TUICallKitCommon.getBundleImage(name: "trtccalling_ic_dialing") {
            imageView.image = image
        }
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    let describeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor.t_colorWithHexString(color: "#199C54")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        return describeLabel
    }()
    
    lazy var timerLabel: UILabel = {
        let timerLabel = UILabel()
        timerLabel.font = UIFont.systemFont(ofSize: 12.0)
        timerLabel.textColor = UIColor.t_colorWithHexString(color: "#199C54")
        timerLabel.textAlignment = .center
        timerLabel.isUserInteractionEnabled = false
        timerLabel.text = viewModel.getCallTimeString()
        return timerLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserveState()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
    }
    
    //MARK: UI Specification Processing
    func setSubView() {
        clearSubview()
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(avatarImageView)
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(describeLabel)
        containerView.addSubview(timerLabel)
    }
    
    func activateConstraints() {
            
        avatarImageView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.top.left.equalTo(self).offset(kMicroContainerViewOffset)
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: kMicroAudioViewWidth - 5, height: kMicroAudioViewHeight - 5))
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(5)
            make.centerX.equalTo(self.containerView)
            make.width.height.equalTo(50)
        }
        
        describeLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(self.containerView)
            make.top.equalTo(self.imageView.snp.bottom)
            make.height.equalTo(20)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(self.containerView)
            make.top.equalTo(self.imageView.snp.bottom)
            make.height.equalTo(20)
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
    
    //MARK: Action Event
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
    
    func registerObserveState() {
        callStatusChange()
    }
        
    func callStatusChange() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
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
    
    //MARK: Update UI
    func updateUI() {
        if viewModel.scence.value == .single {
            if viewModel.mediaType.value == .audio {
                if viewModel.selfCallStatus.value == .waiting {
                    setAudioWaitingUI()
                } else if viewModel.selfCallStatus.value == .accept {
                    setAudioAcceptUI()
                }
            } else if viewModel.mediaType.value == .video {
                if viewModel.selfCallStatus.value == .waiting {
                    setVideoWaitingUI()
                } else if viewModel.selfCallStatus.value == .accept {
                    guard let remoteUser = viewModel.remoteUserList.value.first else { return }
                    if remoteUser.videoAvailable.value == true {
                        setVideoAcceptUI()
                    } else {
                        setVideoAcceptWithDisavailableUI()
                    }
                }
            }
        } else {
            if viewModel.selfCallStatus.value == .waiting {
                setAudioWaitingUI()
            } else if viewModel.selfCallStatus.value == .accept {
                setAudioAcceptUI()
            }
        }
        userVideoAvailableChange()
    }
    
    func setAudioWaitingUI() {
        setSubView()
        avatarImageView.isHidden = true
        containerView.isHidden = false
        describeLabel.isHidden = false
        timerLabel.isHidden = true
        describeLabel.text = TUICallKitLocalize(key: "Demo.TRTC.Calling.FloatingWindow.waitaccept") ?? ""
    }
    
    func setAudioAcceptUI() {
        setSubView()
        avatarImageView.isHidden = true
        containerView.isHidden = false
        describeLabel.isHidden = true
        timerLabel.isHidden = false
                
        viewModel.callTime.addObserver(callTimeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            DispatchCallKitMainAsyncSafe {
                self.timerLabel.text = self.viewModel.getCallTimeString()
            }
        })
    }
    
    func setVideoWaitingUI() {
        setSubView()
        avatarImageView.isHidden = true
        containerView.isHidden = true
        localPreView.frame = kCallKitSingleSmallVideoViewFrame
        addSubview(self.localPreView)
    }
    
    func setVideoAcceptUI() {
        setSubView()
        avatarImageView.isHidden = true
        containerView.isHidden = true
        remotePreView.frame = kCallKitSingleSmallVideoViewFrame
        addSubview(remotePreView)
        
        guard let remoteUser = self.viewModel.remoteUserList.value.first else { return }
        viewModel.startRemoteView(user: remoteUser, videoView: remotePreView)
    }
    
    func setVideoAcceptWithDisavailableUI() {
        setSubView()
        avatarImageView.isHidden = false
        containerView.isHidden = true
        frame = kMicroAudioViewRect

        guard let remoteUser = viewModel.remoteUserList.value.first else { return }
        avatarImageView.image = viewModel.getRemoteAvatar(user: remoteUser)
    }
}
