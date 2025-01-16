//
//  GroupCallerAndCalleeAcceptedView.swift
//  TUICallKit
//
//  Created by noah on 2023/11/8.
//

import Foundation
import SnapKit

protocol GroupCallerAndCalleeAcceptedViewDelegate: AnyObject {
    func showAnimation()
    func restoreExpansion()
    func handleTransform(animationScale: CGFloat)
}

let groupFunctionAnimationDuration = 0.3
let groupFunctionBaseControlBtnHeight = 60.scaleWidth() + 5.scaleHeight() + 20
let groupFunctionBottomHeight = Bottom_SafeHeight > 1 ? Bottom_SafeHeight : 8
let groupFunctionViewHeight = 22 + groupFunctionBaseControlBtnHeight + 20.scaleHeight() + 60.scaleWidth() + groupFunctionBottomHeight
let groupSmallFunctionViewHeight = 22 + 60.scaleWidth() + groupFunctionBottomHeight

class GroupCallerAndCalleeAcceptedView: UIView {
    
    weak var delegate: GroupCallerAndCalleeAcceptedViewDelegate?
    
    let isCameraOpenObserver = Observer()
    let showLargeViewUserIdObserver = Observer()
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()
    
    var isShowLittleContainerView  = false
    var panGestureBeganY = 0.0
    
    lazy var containerView: UIView = {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.t_colorWithHexString(color: "#4F586B")
        containerView.alpha = 0.5
        containerView.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)
        return containerView
    }()
    
    lazy var muteMicBtn: BaseControlButton = {
        let titleKey = TUICallState.instance.isMicMute.value ? "TUICallKit.muted" : "TUICallKit.unmuted"
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: titleKey) ?? "",
                                           imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.muteMicEvent(sender: sender)
        }
        let imageName = TUICallState.instance.isMicMute.value ? "icon_mute_on" : "icon_mute"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return btn
    }()
    
    lazy var closeCameraBtn: BaseControlButton = {
        let titleKey = TUICallState.instance.isCameraOpen.value ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff"
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: titleKey) ?? "",
                                           imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.closeCameraTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: TUICallState.instance.isCameraOpen.value ? "icon_camera_on" : "icon_camera_off") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return btn
    }()
    
    lazy var changeSpeakerBtn: BaseControlButton = {
        let titleKey = (TUICallState.instance.audioDevice.value == .speakerphone) ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece"
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: titleKey) ?? "",
                                           imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.changeSpeakerEvent(sender: sender)
        }
        let imageName = (TUICallState.instance.audioDevice.value == .speakerphone) ? "icon_handsfree_on" : "icon_handsfree"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return btn
    }()
    
    lazy var hangupBtn: BaseControlButton = {
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: "",
                                           imageSize: kBtnSmallSize) { [weak self]  sender in
            guard let self = self else { return }
            self.hangupTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "icon_hangup") {
            btn.updateImage(image: image)
        }
        return btn
    }()
    
    lazy var matchBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self,action:#selector(matchTouchEvent(sender:)), for: .touchUpInside)
        btn.setBackgroundImage(TUICallKitCommon.getBundleImage(name: "icon_match"), for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        setContainerViewCorner()
        let isHidden: Bool = (TUICallState.instance.showLargeViewUserId.value.count <= 1)
        containerView.isHidden = isHidden
        matchBtn.isHidden = isHidden
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(containerView)
        addSubview(muteMicBtn)
        addSubview(changeSpeakerBtn)
        addSubview(closeCameraBtn)
        addSubview(hangupBtn)
        addSubview(matchBtn)
    }
    
    func activateConstraints() {
        let top = 22.0
        containerView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: frame.size.width, height: groupFunctionViewHeight))
        
        muteMicBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 110.scaleWidth() : -110.scaleWidth())
            make.centerY.equalTo(changeSpeakerBtn)
            make.width.height.equalTo(60.scaleWidth())
        }
        changeSpeakerBtn.snp.makeConstraints { make in
            make.top.equalTo(self).offset(top)
            make.centerX.equalTo(self)
            make.width.height.equalTo(60.scaleWidth())
        }
        closeCameraBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -110.scaleWidth() : 110.scaleWidth())
            make.centerY.equalTo(self.changeSpeakerBtn)
            make.width.height.equalTo(60.scaleWidth())
        }
        hangupBtn.snp.makeConstraints { make in
            make.top.equalTo(changeSpeakerBtn.snp.bottom).offset(5.scaleHeight() + 20 + 20.scaleHeight())
            make.centerX.equalTo(self)
            make.width.height.equalTo(60.scaleWidth())
        }
        matchBtn.snp.makeConstraints { make in
            make.centerY.equalTo(hangupBtn)
            make.leading.width.height.equalTo(30.scaleWidth())
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateCloseCameraBtn(open: newValue)
        })
        
        TUICallState.instance.showLargeViewUserId.addObserver(showLargeViewUserIdObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            if newValue.count > 1 {
                self.showAnimation()
                self.containerView.isHidden = false
                self.matchBtn.isHidden = false
            } else {
                self.restoreExpansion()
            }
        }
        
        TUICallState.instance.isMicMute.addObserver(isMicMuteObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateMuteAudioBtn(mute: newValue)
        })
        
        TUICallState.instance.audioDevice.addObserver(audioDeviceObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateChangeSpeakerBtn(isSpeaker: newValue == .speakerphone)
        })
    }
    
    // MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        CallEngineManager.instance.muteMic()
        updateMuteAudioBtn(mute: TUICallState.instance.isMicMute.value == true)
    }
    
    func closeCameraTouchEvent(sender: UIButton) {
        updateCloseCameraBtn(open: TUICallState.instance.isCameraOpen.value != true)
        if TUICallState.instance.isCameraOpen.value == true {
            CallEngineManager.instance.closeCamera()
        } else {
            guard let videoViewEntity = VideoFactory.instance.viewMap[TUICallState.instance.selfUser.value.id.value] else { return }
            CallEngineManager.instance.openCamera(videoView: videoViewEntity.videoView)
        }
    }
    
    func changeSpeakerEvent(sender: UIButton) {
        CallEngineManager.instance.changeSpeaker()
        updateChangeSpeakerBtn(isSpeaker: TUICallState.instance.audioDevice.value == .speakerphone)
    }
    
    @objc func hangupTouchEvent(sender: UIButton) {
        CallEngineManager.instance.hangup()
    }
    
    @objc func matchTouchEvent(sender: UIButton) {
        if isShowLittleContainerView {
            restoreExpansion()
        } else {
            showAnimation()
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: containerView)
        let scale = ((translation.y - panGestureBeganY) / 105)
        
        if gesture.state == .began {
            panGestureBeganY = translation.y
        } else if gesture.state == .changed {
            if scale > 0 && !isShowLittleContainerView {
                // Swipe down
                handleTransform(animationScale: (scale > 1) ? 1 : scale)
            } else if scale < 0 && isShowLittleContainerView  {
                // Swipe up
                handleTransform(animationScale: (scale < -1) ? 0 : (1 + scale))
            }
        } else if gesture.state == .ended {
            if scale > 0 {
                // Swipe down
                if (scale > 0.5) {
                    showAnimation()
                } else {
                    restoreExpansion()
                }
            } else {
                // Swipe up
                if (scale < -0.5) {
                    restoreExpansion()
                } else {
                    showAnimation()
                }
            }
        }
    }
    
    func showAnimation() {
        isShowLittleContainerView = true
        delegate?.showAnimation()
        
        UIView.animate(withDuration: groupFunctionAnimationDuration) {
            self.handleTransform(animationScale: 1)
        }
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi)
        rotationAnimation.duration = groupFunctionAnimationDuration
        rotationAnimation.fillMode = .forwards
        rotationAnimation.isRemovedOnCompletion = false
        self.matchBtn.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func restoreExpansion() {
        isShowLittleContainerView = false
        delegate?.restoreExpansion()
        
        UIView.animate(withDuration: groupFunctionAnimationDuration, animations: {
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
        self.matchBtn.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func handleTransform(animationScale: CGFloat) {
        delegate?.handleTransform(animationScale: animationScale)
        
        let alpha: CGFloat = 1 - 1 * animationScale
        let scale: CGFloat = 1 - 1 / 3 * animationScale
        let muteMicX = ((TUICoreDefineConvert.getIsRTL() ? -28 : 28) * animationScale).scaleWidth()
        let changeSpeakerX = ((TUICoreDefineConvert.getIsRTL() ? 2 : -2) * animationScale).scaleWidth()
        let closeCameraX = ((TUICoreDefineConvert.getIsRTL() ? 28 : -28) * animationScale).scaleWidth()
        let hangupX = ((TUICoreDefineConvert.getIsRTL() ? -138 : 138) * animationScale).scaleWidth()
        let hangupTranslationY = -(groupFunctionBaseControlBtnHeight + 20.scaleHeight()) * animationScale
        let titleLabelTranslationY = -12.scaleWidth() * animationScale
        
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
        
        self.muteMicBtn.transform = CGAffineTransform(translationX: muteMicX, y: 0)
        self.changeSpeakerBtn.transform = CGAffineTransform(translationX: changeSpeakerX, y: 0)
        self.closeCameraBtn.transform = CGAffineTransform(translationX: closeCameraX, y: 0)
        self.hangupBtn.transform = CGAffineTransform(translationX: hangupX, y: hangupTranslationY)
        self.matchBtn.transform = CGAffineTransform(translationX: 0, y: hangupTranslationY)
    }
    
    // MARK: Update UI
    func updateMuteAudioBtn(mute: Bool) {
        muteMicBtn.updateTitle(title: TUICallKitLocalize(key: mute ? "TUICallKit.muted" : "TUICallKit.unmuted") ?? "")
        
        if let image = TUICallKitCommon.getBundleImage(name: mute ? "icon_mute_on" : "icon_mute") {
            muteMicBtn.updateImage(image: image)
        }
    }
    
    func updateChangeSpeakerBtn(isSpeaker: Bool) {
        changeSpeakerBtn.updateTitle(title: TUICallKitLocalize(key: isSpeaker ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece") ?? "")
        
        if let image = TUICallKitCommon.getBundleImage(name: isSpeaker ? "icon_handsfree_on" : "icon_handsfree") {
            changeSpeakerBtn.updateImage(image: image)
        }
    }
    
    func updateCloseCameraBtn(open: Bool) {
        closeCameraBtn.updateTitle(title: TUICallKitLocalize(key: open ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff") ?? "")
        
        if let image = TUICallKitCommon.getBundleImage(name: open ? "icon_camera_on" : "icon_camera_off") {
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
}
