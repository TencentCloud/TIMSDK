//
//  FloatWindowGroupView.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/25.
//

import RTCCommon

class FloatWindowGroupView: UIView {
        
    private let selfCallStatusObserver = Observer()
    private let callTimeObserver = Observer()
    private var remoteUserVideoView: VideoView? = nil

    let shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                    defaultHex:  "#FFFFFF")
        shadowView.layer.shadowColor = UIColor(hex: "353941")?.cgColor
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 4.scale375Width()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.cornerRadius = 12.scale375Width()
        return shadowView
    }()

    let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                       defaultHex:  "#FFFFFF")
        containerView.layer.cornerRadius = 12.scale375Width()
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    let callStateView: UIView = {
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
    let describeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor(hex: "#12B969")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        describeLabel.text = TUICallKitLocalize(key: "TUICallKit.FloatingWindow.waitAccept") ?? ""
        return describeLabel
    }()
    
    let mediaStatusView: UIView = UIView()
    let videoImageView: UIImageView = {
        let imageView = UIImageView()
        let imageName = CallManager.shared.mediaState.isCameraOpened.value ? "icon_float_group_video_on" : "icon_float_group_video_off"
        if let image = CallKitBundle.getBundleImage(name: imageName) {
            imageView.image = image
        }
        return imageView
    }()
    
    let audioImageView: UIImageView = {
        let imageView = UIImageView()
        let imageName = CallManager.shared.mediaState.isMicrophoneMuted.value ? "icon_float_group_audio_off" : "icon_float_group_audio_on"
        if let image = CallKitBundle.getBundleImage(name: imageName) {
            imageView.image = image
        }
        return imageView
    }()

    // MARK: init、 deinit
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserver()
        
        constructViewHierarchy()
        activateConstraints()
        
        setCallStateView()
        setCurrentSpeakerView()
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
        
        containerView.addSubview(callStateView)
        callStateView.addSubview(imageView)
        callStateView.addSubview(describeLabel)
        
        containerView.addSubview(mediaStatusView)
        mediaStatusView.addSubview(videoImageView)
        mediaStatusView.addSubview(audioImageView)
    }
    
    func activateConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = containerView.superview {
            NSLayoutConstraint.activate([
                containerView.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
                containerView.centerYAnchor.constraint(equalTo: superview.centerYAnchor),
                containerView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 8.scale375Width()),
                containerView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 8.scale375Width())
            ])
        }

        shadowView.translatesAutoresizingMaskIntoConstraints = false
        if let containerSuperview = containerView.superview, let superview = shadowView.superview, superview == containerSuperview {
            NSLayoutConstraint.activate([
                shadowView.topAnchor.constraint(equalTo: containerView.topAnchor),
                shadowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                shadowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                shadowView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }

        callStateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            callStateView.topAnchor.constraint(equalTo: containerView.topAnchor),
            callStateView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            callStateView.widthAnchor.constraint(equalToConstant: 72.scale375Width()),
            callStateView.heightAnchor.constraint(equalToConstant: 72.scale375Width())
        ])

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: callStateView.topAnchor, constant: 8.scale375Width()),
            imageView.centerXAnchor.constraint(equalTo: callStateView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 36.scale375Width()),
            imageView.heightAnchor.constraint(equalToConstant: 36.scale375Width())
        ])

        describeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            describeLabel.centerXAnchor.constraint(equalTo: callStateView.centerXAnchor),
            describeLabel.widthAnchor.constraint(equalTo: callStateView.widthAnchor),
            describeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4.scale375Width()),
            describeLabel.heightAnchor.constraint(equalToConstant: 20.scale375Width())
        ])

        mediaStatusView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mediaStatusView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            mediaStatusView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            mediaStatusView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            mediaStatusView.heightAnchor.constraint(equalToConstant: 20.scale375Width())
        ])

        videoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoImageView.centerYAnchor.constraint(equalTo: mediaStatusView.centerYAnchor),
            videoImageView.leadingAnchor.constraint(equalTo: mediaStatusView.leadingAnchor, constant: 14.scale375Width()),
            videoImageView.widthAnchor.constraint(equalToConstant: 16.scale375Width()),
            videoImageView.heightAnchor.constraint(equalToConstant: 16.scale375Width())
        ])

        audioImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            audioImageView.centerYAnchor.constraint(equalTo: mediaStatusView.centerYAnchor),
            audioImageView.trailingAnchor.constraint(equalTo: mediaStatusView.trailingAnchor, constant: -14.scale375Width()),
            audioImageView.widthAnchor.constraint(equalToConstant: 16.scale375Width()),
            audioImageView.heightAnchor.constraint(equalToConstant: 16.scale375Width())
        ])
    }
        
    // MARK: Register TUICallState Observer && Update UI
    func registerObserver() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setCallStateView()
            self.setCurrentSpeakerView()
        })

        CallManager.shared.callState.callDurationCount.addObserver(callTimeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setCallStateView()
            self.setCurrentSpeakerView()
        })
    }
    
    func unregisterObserver() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(selfCallStatusObserver)
        CallManager.shared.callState.callDurationCount.removeObserver(callTimeObserver)
    }
    
    // MARK: Update UI
    func setCallStateView() {
        if CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            describeLabel.text = TUICallKitLocalize(key: "TUICallKit.FloatingWindow.waitAccept")
        } else if CallManager.shared.userState.selfUser.callStatus.value == .accept {
            describeLabel.text = GCDTimer.secondToHMSString(second: CallManager.shared.callState.callDurationCount.value)
        }
    }
    
    func setCurrentSpeakerView() {
        remoteUserVideoView?.removeFromSuperview()

        guard let user = getCurrentSpeakerUser() else { return }
        guard let videoView = VideoFactory.shared.createVideoView(user: user, isShowFloatWindow: true) else { return }
        remoteUserVideoView = videoView
        addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoView.topAnchor.constraint(equalTo: containerView.topAnchor),
            videoView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            videoView.widthAnchor.constraint(equalToConstant: 72.scale375Width()),
            videoView.heightAnchor.constraint(equalToConstant: 72.scale375Width())
        ])
        if user.id.value != CallManager.shared.userState.selfUser.id.value {
            CallManager.shared.startRemoteView(user: user, videoView: videoView.getVideoView())
        }
    }
    
    func getCurrentSpeakerUser() -> User? {
        for user in CallManager.shared.userState.remoteUserList.value {
            if user.playoutVolume.value >= 10 {
                return user
            }
        }
        if CallManager.shared.userState.selfUser.playoutVolume.value >= 10 {
            return CallManager.shared.userState.selfUser
        }
        return nil
    }
}
