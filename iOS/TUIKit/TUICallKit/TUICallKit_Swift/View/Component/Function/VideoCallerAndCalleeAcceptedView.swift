//
//  VideoCallerAndCalleeAcceptedView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import RTCCommon

let groupFunctionAnimationDuration = 0.3
let groupFunctionBaseControlBtnHeight = 60.scale375Width() + 5.scale375Height() + 20
let groupFunctionBottomHeight = Bottom_SafeHeight > 1 ? Bottom_SafeHeight : 8
let groupFunctionViewHeight = 220.scale375Height()
let groupSmallFunctionViewHeight = 116.scale375Height()

class VideoCallerAndCalleeAcceptedView: UIView {
    
    let isCameraOpenObserver = Observer()
    let showLargeViewUserIdObserver = Observer()
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()
    
    var isShowLittleContainerView  = false
    
    let containerView: UIView = {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor(hex: "#4F586B")
        containerView.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
        return containerView
    }()
    
    private lazy var muteMicBtn: FeatureButton = {
        let titleKey = CallManager.shared.mediaState.isMicrophoneMuted.value ? "TUICallKit.muted" : "TUICallKit.unmuted"
        let imageName =  CallManager.shared.mediaState.isMicrophoneMuted.value ? "icon_mute_on" : "icon_mute"

        let muteAudioBtn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                                titleColor: Color_White,
                                                image: CallKitBundle.getBundleImage(name: imageName),
                            imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.muteMicEvent(sender: sender)
        })
        return muteAudioBtn
    }()

    private lazy var closeCameraBtn: FeatureButton = {
        let titleKey = CallManager.shared.mediaState.isCameraOpened.value ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff"
        let imageName = CallManager.shared.mediaState.isCameraOpened.value ? "icon_camera_on" : "icon_camera_off"
        let btn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                       titleColor: Color_White,
                                       image: CallKitBundle.getBundleImage(name: imageName),
                                       imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.closeCameraTouchEvent(sender: sender)
        }
        return btn
    }()

    private lazy var changeSpeakerBtn: FeatureButton = {
        let titleKey = CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece"
        let imageName = CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone ? "icon_handsfree_on" : "icon_handsfree"

        let changeSpeakerBtn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                                    titleColor: Color_White,
                                                    image: CallKitBundle.getBundleImage(name: imageName),
                                                    imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.changeSpeakerEvent(sender: sender)
        })

        return changeSpeakerBtn
    }()

    private lazy var hangupBtn: FeatureButton = {
        let btn = FeatureButton.create(title: nil,
                                       titleColor: Color_White,
                                       image: CallKitBundle.getBundleImage(name: "icon_hangup"),
                                       imageSize: kBtnLargeSize) { [weak self] sender in
            guard let self = self else { return }
            self.hangupTouchEvent(sender: sender)
        }
        return btn
    }()

    let switchCameraBtn: UIButton = {
           let btn = UIButton(type: .system)
           if let image = CallKitBundle.getBundleImage(name: "switch_camera") {
               btn.setBackgroundImage(image, for: .normal)
           }
           btn.addTarget(self, action: #selector(switchCameraTouchEvent(sender:)), for: .touchUpInside)
           return btn
    }()
    
    let virtualBackgroundButton: UIButton = {
            let btn = UIButton(type: .system)
            if let image = CallKitBundle.getBundleImage(name: "virtual_background") {
                btn.setBackgroundImage(image, for: .normal)
            }
            btn.addTarget(self, action: #selector(virtualBackgroundTouchEvent(sender:)), for: .touchUpInside)
            return btn
        }()
    
    let matchBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action:#selector(matchTouchEvent(sender:)), for: .touchUpInside)
        btn.setBackgroundImage(CallKitBundle.getBundleImage(name: "icon_match"), for: .normal)
        return btn
    }()
    
    // MARK: init，deinit
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        updateViewHidden()
        registerObserve()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterObserve()
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        setContainerViewCorner()
    }
    
    func constructViewHierarchy() {
        addSubview(containerView)
        addSubview(muteMicBtn)
        addSubview(changeSpeakerBtn)
        addSubview(closeCameraBtn)
        addSubview(hangupBtn)
        addSubview(matchBtn)
        addSubview(switchCameraBtn)
        addSubview(virtualBackgroundButton)
    }
    
    func activateConstraints() {
        let top = 22.0
        containerView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.size.width, height: groupFunctionViewHeight))
        
        muteMicBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            muteMicBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: TUICoreDefineConvert.getIsRTL() ? 110.scale375Width() : -110.scale375Width()),
            muteMicBtn.centerYAnchor.constraint(equalTo: changeSpeakerBtn.centerYAnchor),
            muteMicBtn.widthAnchor.constraint(equalToConstant: 60.scale375Width()),
            muteMicBtn.heightAnchor.constraint(equalToConstant: 60.scale375Width())
        ])

        changeSpeakerBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            changeSpeakerBtn.topAnchor.constraint(equalTo: self.topAnchor, constant: top),
            changeSpeakerBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            changeSpeakerBtn.widthAnchor.constraint(equalToConstant: 60.scale375Width()),
            changeSpeakerBtn.heightAnchor.constraint(equalToConstant: 60.scale375Width())
        ])

        closeCameraBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeCameraBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: TUICoreDefineConvert.getIsRTL() ? -110.scale375Width() : 110.scale375Width()),
            closeCameraBtn.centerYAnchor.constraint(equalTo: changeSpeakerBtn.centerYAnchor),
            closeCameraBtn.widthAnchor.constraint(equalToConstant: 60.scale375Width()),
            closeCameraBtn.heightAnchor.constraint(equalToConstant: 60.scale375Width())
        ])

        hangupBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hangupBtn.topAnchor.constraint(equalTo: changeSpeakerBtn.bottomAnchor, constant: 5.scale375Height() + 20 + 20.scale375Height()),
            hangupBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            hangupBtn.widthAnchor.constraint(equalToConstant: 60.scale375Width()),
            hangupBtn.heightAnchor.constraint(equalToConstant: 60.scale375Width())
        ])

        matchBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            matchBtn.centerYAnchor.constraint(equalTo: hangupBtn.centerYAnchor),
            matchBtn.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30.scale375Width()),
            matchBtn.widthAnchor.constraint(equalToConstant: 30.scale375Width()),
            matchBtn.heightAnchor.constraint(equalToConstant: 30.scale375Width())
        ])

        switchCameraBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            switchCameraBtn.centerYAnchor.constraint(equalTo: hangupBtn.centerYAnchor),
            switchCameraBtn.leadingAnchor.constraint(equalTo: hangupBtn.trailingAnchor, constant: 40.scale375Width()),
            switchCameraBtn.widthAnchor.constraint(equalToConstant: 28.scale375Width()),
            switchCameraBtn.heightAnchor.constraint(equalToConstant: 28.scale375Width())
        ])
        
        virtualBackgroundButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            virtualBackgroundButton.centerYAnchor.constraint(equalTo: hangupBtn.centerYAnchor),
            virtualBackgroundButton.trailingAnchor.constraint(equalTo: hangupBtn.leadingAnchor, constant: -40.scale375Width()),
            virtualBackgroundButton.widthAnchor.constraint(equalToConstant: 28.scale375Width()),
            virtualBackgroundButton.heightAnchor.constraint(equalToConstant: 28.scale375Width())
        ])
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserve() {
        CallManager.shared.mediaState.isCameraOpened.addObserver(isCameraOpenObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateCloseCameraBtn(open: newValue)
        })
        
        CallManager.shared.viewState.showLargeViewUserId.addObserver(showLargeViewUserIdObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            if !newValue.isEmpty {
                self.setNonExpansion()
            }
        }
        
        CallManager.shared.mediaState.isMicrophoneMuted.addObserver(isMicMuteObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateMuteAudioBtn(mute: newValue)
        })
        
        CallManager.shared.mediaState.audioPlayoutDevice.addObserver(audioDeviceObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateChangeSpeakerBtn(isSpeaker: newValue == .speakerphone)
        })
    }
    
    func unregisterObserve() {
        CallManager.shared.mediaState.isCameraOpened.removeObserver(isCameraOpenObserver)
        CallManager.shared.viewState.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
        CallManager.shared.mediaState.isMicrophoneMuted.removeObserver(isMicMuteObserver)
        CallManager.shared.mediaState.audioPlayoutDevice.removeObserver(audioDeviceObserver)
    }
    
    // MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        CallManager.shared.muteMic()
        updateMuteAudioBtn(mute: CallManager.shared.mediaState.isMicrophoneMuted.value == true)
    }
    
    func closeCameraTouchEvent(sender: UIButton) {
        updateCloseCameraBtn(open: CallManager.shared.mediaState.isCameraOpened.value != true)
        if CallManager.shared.mediaState.isCameraOpened.value == true {
            CallManager.shared.closeCamera()
        } else {
            guard let videoViewEntity = VideoFactory.shared.createVideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: false) else { return }
            CallManager.shared.openCamera(videoView: videoViewEntity.getVideoView()) { } fail: { code, message in }
        }
    }
    
    func changeSpeakerEvent(sender: UIButton) {
        CallManager.shared.changeSpeaker()
        updateChangeSpeakerBtn(isSpeaker: CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone)
    }
    
    @objc func hangupTouchEvent(sender: UIButton) {
        CallManager.shared.hangup() { } fail: { code, message in }
    }
    
    @objc func switchCameraTouchEvent(sender: UIButton) {
        CallManager.shared.switchCamera()
    }
        
    @objc func virtualBackgroundTouchEvent(sender: UIButton) {
        CallManager.shared.setBlurBackground(enable: CallManager.shared.viewState.isVirtualBackgroundOpened.value ? false : true)
    }
    
    @objc func matchTouchEvent(sender: UIButton) {
        if isShowLittleContainerView {
            setExpansion()
        } else {
            setNonExpansion()
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let scale = gesture.translation(in: containerView).y / 105
        if gesture.state == .ended {
            if scale > 0 {
                // Swipe down
                if (scale > 0.5) {
                    setNonExpansion()
                } else {
                    setExpansion()
                }
            } else {
                // Swipe up
                if (scale < -0.5) {
                    setExpansion()
                } else {
                    setNonExpansion()
                }
            }
        }
    }
    
    // MARK: Update UI
    func updateViewHidden() {
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            switchCameraBtn.isHidden = false
            virtualBackgroundButton.isHidden = CallManager.shared.globalState.enableVirtualBackground ? false : true
            containerView.isHidden = true
            matchBtn.isHidden = true
            return
        }
            
        switchCameraBtn.isHidden = true
        virtualBackgroundButton.isHidden = true
        containerView.isHidden = false
        matchBtn.isHidden = false
    }
    
    func updateMuteAudioBtn(mute: Bool) {
        muteMicBtn.updateTitle(title: TUICallKitLocalize(key: mute ? "TUICallKit.muted" : "TUICallKit.unmuted") ?? "")
        
        if let image = CallKitBundle.getBundleImage(name: mute ? "icon_mute_on" : "icon_mute") {
            muteMicBtn.updateImage(image: image)
        }
    }
    
    func updateChangeSpeakerBtn(isSpeaker: Bool) {
        changeSpeakerBtn.updateTitle(title: TUICallKitLocalize(key: isSpeaker ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece") ?? "")
        
        if let image = CallKitBundle.getBundleImage(name: isSpeaker ? "icon_handsfree_on" : "icon_handsfree") {
            changeSpeakerBtn.updateImage(image: image)
        }
    }
    
    func updateCloseCameraBtn(open: Bool) {
        closeCameraBtn.updateTitle(title: TUICallKitLocalize(key: open ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff") ?? "")
        
        if let image = CallKitBundle.getBundleImage(name: open ? "icon_camera_on" : "icon_camera_off") {
            closeCameraBtn.updateImage(image: image)
        }
    }
    
    func setContainerViewCorner() {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: containerView.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: 20, height: 20))
        maskLayer.path = path.cgPath
        containerView.layer.mask = maskLayer
    }
    
    // MARK: GroupCallerAndCalleeAcceptedViewDelegate
    func setNonExpansion() {
        if isShowLittleContainerView == true { return }
        isShowLittleContainerView = true
        
        UIView.animate(withDuration: groupFunctionAnimationDuration) {
            self.containerView.frame = CGRect(origin: CGPoint(x: 0, y: self.frame.size.height - groupSmallFunctionViewHeight), size: CGSize(width: self.frame.size.width, height: groupSmallFunctionViewHeight))

            let alpha: CGFloat = 0
            let scale: CGFloat = 2 / 3
            let muteMicX = ((TUICoreDefineConvert.getIsRTL() ? -24 : 24) ).scale375Width()
            let changeSpeakerX = ((TUICoreDefineConvert.getIsRTL() ? 10 : -10)).scale375Width()
            let closeCameraX = ((TUICoreDefineConvert.getIsRTL() ? 44 : -44) ).scale375Width()
            let hangupX = ((TUICoreDefineConvert.getIsRTL() ? -140 : 140)).scale375Width()
            let hangupTranslationY = -(groupFunctionBaseControlBtnHeight + 20.scale375Height())
            let titleLabelTranslationY = -12.scale375Width()
            
            self.muteMicBtn.titleLabel.alpha = alpha
            self.changeSpeakerBtn.titleLabel.alpha = alpha
            self.closeCameraBtn.titleLabel.alpha = alpha
            
            self.muteMicBtn.titleLabel.transform = CGAffineTransform(translationX: 0, y: titleLabelTranslationY)
            self.changeSpeakerBtn.titleLabel.transform = CGAffineTransform(translationX: 0, y: titleLabelTranslationY)
            self.closeCameraBtn.titleLabel.transform = CGAffineTransform(translationX: 0, y: titleLabelTranslationY)
            
            self.muteMicBtn.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.changeSpeakerBtn.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.closeCameraBtn.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.hangupBtn.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            self.muteMicBtn.transform = CGAffineTransform(translationX: muteMicX, y: -hangupTranslationY)
            self.changeSpeakerBtn.transform = CGAffineTransform(translationX: changeSpeakerX, y: -hangupTranslationY)
            self.closeCameraBtn.transform = CGAffineTransform(translationX: closeCameraX, y: -hangupTranslationY)
            self.hangupBtn.transform = CGAffineTransform(translationX: hangupX, y: 0)
            self.matchBtn.transform = CGAffineTransform(translationX: 0, y: 0)
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi)
        rotationAnimation.duration = groupFunctionAnimationDuration
        rotationAnimation.fillMode = .forwards
        rotationAnimation.isRemovedOnCompletion = false
        matchBtn.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func setExpansion() {
        if isShowLittleContainerView == false { return }
        isShowLittleContainerView = false
        
        UIView.animate(withDuration: groupFunctionAnimationDuration, animations: {
            self.containerView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.frame.size.width, height: groupFunctionViewHeight))

            self.muteMicBtn.titleLabel.alpha = 1
            self.changeSpeakerBtn.titleLabel.alpha = 1
            self.closeCameraBtn.titleLabel.alpha = 1
            
            self.muteMicBtn.titleLabel.transform = CGAffineTransform.identity
            self.changeSpeakerBtn.titleLabel.transform = CGAffineTransform.identity
            self.closeCameraBtn.titleLabel.transform = CGAffineTransform.identity
            
            self.muteMicBtn.button.transform = CGAffineTransform.identity
            self.changeSpeakerBtn.button.transform = CGAffineTransform.identity
            self.closeCameraBtn.button.transform = CGAffineTransform.identity
            self.hangupBtn.button.transform = CGAffineTransform.identity
            
            self.muteMicBtn.transform = CGAffineTransform.identity
            self.changeSpeakerBtn.transform = CGAffineTransform.identity
            self.closeCameraBtn.transform = CGAffineTransform.identity
            self.hangupBtn.transform = CGAffineTransform.identity
            self.matchBtn.transform = CGAffineTransform.identity
        })
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: 0.0)
        rotationAnimation.duration = groupFunctionAnimationDuration
        rotationAnimation.fillMode = .forwards
        rotationAnimation.isRemovedOnCompletion = true
        matchBtn.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
}
