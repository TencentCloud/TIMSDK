//
//  FloatWindowSingleView.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/25.
//

import RTCCommon

class  FloatWindowSingleView: UIView {
    let selfCallStatusObserver = Observer()
    let remoteVideoAvailableObserver = Observer()
    let callTimeObserver = Observer()
    
    let kFloatingWindowVideoViewRect = CGRect(x: 0,
                                              y: 0,
                                              width: kMicroVideoViewWidth - 16.scale375Width(),
                                              height: kMicroVideoViewHeight - 16.scale375Width())
        
    let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                       defaultHex:  "#FFFFFF")
        containerView.layer.cornerRadius = 12.scale375Width()
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    let shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                    defaultHex:  "#FFFFFF")
        shadowView.layer.shadowColor = UIColor(hex: "353941")?.cgColor
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.cornerRadius = 12.scale375Width()
        shadowView.layer.shadowRadius = 4.scale375Width()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        return shadowView
    }()
    
    let audioContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                       defaultHex:  "#FFFFFF")
        return containerView
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        if let image = CallKitBundle.getBundleImage(name: "icon_float_dialing") {
            imageView.image = image
        }
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    let audioDescribeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor(hex: "#12B969")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        describeLabel.text = TUICallKitLocalize(key: "TUICallKit.FloatingWindow.waitAccept") ?? ""
        return describeLabel
    }()
    let timerLabel: UILabel = {
        let timerLabel = UILabel()
        timerLabel.font = UIFont.systemFont(ofSize: 12.0)
        timerLabel.textColor = UIColor(hex: "#12B969")
        timerLabel.textAlignment = .center
        timerLabel.isUserInteractionEnabled = false
        timerLabel.text = GCDTimer.secondToHMSString(second: CallManager.shared.callState.callDurationCount.value)
        return timerLabel
    }()
    
    private let videoContainerView: UIView = UIView()
    private var selfVideoView: VideoView {
        guard let videoView = VideoFactory.shared.createVideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: false) else {
            TRTCLog.error("TUICallKit - FloatWindowSingleView::selfVideoView, create video view failed")
            return VideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: true)
        }
        return videoView
    }
    private var remoteVideoView: VideoView {
        if let remoteUser = CallManager.shared.userState.remoteUserList.value.first {
            if let videoView = VideoFactory.shared.createVideoView(user: remoteUser, isShowFloatWindow: true) {
                return videoView
            }
        }
        TRTCLog.error("TUICallKit - FloatWindowSingleView::selfVideoView, create video view failed")
        return VideoView(user: User(), isShowFloatWindow: false)
    }
    let videoDescribeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor(hex: "#FFFFFF")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        describeLabel.text = TUICallKitLocalize(key: "TUICallKit.FloatingWindow.waitAccept") ?? ""
        return describeLabel
    }()
    
    // MARK: init、deinit
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserver()
        
        constructViewHierarchy()
        activateConstraints()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterObserver()
    }
    
    func constructViewHierarchy() {
        addSubview(shadowView)
        addSubview(containerView)
        
        containerView.addSubview(audioContainerView)
        audioContainerView.addSubview(imageView)
        audioContainerView.addSubview(audioDescribeLabel)
        audioContainerView.addSubview(timerLabel)
        
        containerView.addSubview(videoContainerView)
        videoContainerView.addSubview(selfVideoView)
        videoContainerView.addSubview(remoteVideoView)
        videoContainerView.addSubview(videoDescribeLabel)
    }
    
    func activateConstraints() {
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = shadowView.superview, let containerSuperview = containerView.superview, superview == containerSuperview {
            NSLayoutConstraint.activate([
                shadowView.topAnchor.constraint(equalTo: containerView.topAnchor),
                shadowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                shadowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                shadowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }

        containerView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = containerView.superview {
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                containerView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 8.scale375Width()),
                containerView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 8.scale375Width())
            ])
        }

        audioContainerView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = audioContainerView.superview {
            NSLayoutConstraint.activate([
                audioContainerView.topAnchor.constraint(equalTo: containerView.topAnchor),
                audioContainerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                audioContainerView.widthAnchor.constraint(equalToConstant: 72.scale375Width()),
                audioContainerView.heightAnchor.constraint(equalToConstant: 72.scale375Width())
            ])
        }

        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = imageView.superview {
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: audioContainerView.topAnchor, constant: 8.scale375Width()),
                imageView.centerXAnchor.constraint(equalTo: audioContainerView.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 36.scale375Width()),
                imageView.heightAnchor.constraint(equalToConstant: 36.scale375Width())
            ])
        }

        audioDescribeLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = audioDescribeLabel.superview {
            NSLayoutConstraint.activate([
                audioDescribeLabel.centerXAnchor.constraint(equalTo: audioContainerView.centerXAnchor),
                audioDescribeLabel.widthAnchor.constraint(equalTo: audioContainerView.widthAnchor),
                audioDescribeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4.scale375Width()),
                audioDescribeLabel.heightAnchor.constraint(equalToConstant: 20.scale375Width())
            ])
        }

        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = timerLabel.superview {
            NSLayoutConstraint.activate([
                timerLabel.centerXAnchor.constraint(equalTo: audioContainerView.centerXAnchor),
                timerLabel.widthAnchor.constraint(equalTo: audioContainerView.widthAnchor),
                timerLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4.scale375Width()),
                timerLabel.heightAnchor.constraint(equalToConstant: 20.scale375Width())
            ])
        }

        videoContainerView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = videoContainerView.superview {
            NSLayoutConstraint.activate([
                videoContainerView.topAnchor.constraint(equalTo: superview.topAnchor),
                videoContainerView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                videoContainerView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                videoContainerView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }

        videoDescribeLabel.translatesAutoresizingMaskIntoConstraints = false
        if let superview = videoDescribeLabel.superview {
            NSLayoutConstraint.activate([
                videoDescribeLabel.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                videoDescribeLabel.widthAnchor.constraint(equalTo: superview.widthAnchor),
                videoDescribeLabel.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -8.scale375Width()),
                videoDescribeLabel.heightAnchor.constraint(equalToConstant: 20.scale375Width())
            ])
        }
            
        remoteVideoView.frame = kFloatingWindowVideoViewRect
        selfVideoView.frame = kFloatingWindowVideoViewRect
    }
        
    // MARK: Register TUICallState Observer && Update UI
    func registerObserver() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        })
        
        CallManager.shared.callState.callDurationCount.addObserver(callTimeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            CallKitDispatchQueue.mainAsyncSafe {
                self.timerLabel.text = GCDTimer.secondToHMSString(second: newValue)
            }
        })
        
        CallManager.shared.userState.remoteUserList.value.first?.videoAvailable.addObserver(remoteVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        })
    }
    
    func unregisterObserver() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(selfCallStatusObserver)
        CallManager.shared.callState.callDurationCount.removeObserver(callTimeObserver)
        CallManager.shared.userState.remoteUserList.value.first?.videoAvailable.removeObserver(remoteVideoAvailableObserver)
    }
    
    // MARK: Update UI
    func updateUI() {
        cleanView()
        
        if CallManager.shared.callState.mediaType.value == .audio {
            updateAudioUI()
        } else if CallManager.shared.callState.mediaType.value == .video {
            updateVideoUI()
        }
    }
    
    func updateAudioUI() {
        containerView.backgroundColor = UIColor(hex: "FFFFFF")
        if CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            audioContainerView.isHidden = false
            imageView.isHidden = false
            audioDescribeLabel.isHidden = false
        } else if CallManager.shared.userState.selfUser.callStatus.value == .accept {
            audioContainerView.isHidden = false
            imageView.isHidden = false
            timerLabel.isHidden = false
        }
    }
    
    func updateVideoUI() {
        if CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            videoContainerView.isHidden = false
            selfVideoView.isHidden = false
            videoDescribeLabel.isHidden = false
        } else if CallManager.shared.userState.selfUser.callStatus.value == .accept {
            videoContainerView.isHidden = false
            remoteVideoView.isHidden = false
            
            guard let remoteUser = CallManager.shared.userState.remoteUserList.value.first else { return }
            CallManager.shared.startRemoteView(user: remoteUser, videoView: remoteVideoView.getVideoView())
        }
    }
    
    func cleanView() {
        audioContainerView.isHidden = true
        imageView.isHidden = true
        audioDescribeLabel.isHidden = true
        timerLabel.isHidden = true
        videoContainerView.isHidden = true
        selfVideoView.isHidden = true
        remoteVideoView.isHidden = true
        videoDescribeLabel.isHidden = true
    }
}
