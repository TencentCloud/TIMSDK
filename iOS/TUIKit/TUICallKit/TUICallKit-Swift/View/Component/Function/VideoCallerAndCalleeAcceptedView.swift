//
//  VideoCallerAndCalleeAcceptedView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import SnapKit

class VideoCallerAndCalleeAcceptedView: UIView {
    
    let isCameraOpenObserver = Observer()
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()

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
        let imageName = TUICallState.instance.isCameraOpen.value ? "icon_camera_on" : "icon_camera_off"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
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
    
    lazy var hangupBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self,action:#selector(hangupTouchEvent(sender:)), for: .touchUpInside)
        btn.setBackgroundImage(TUICallKitCommon.getBundleImage(name: "icon_hangup"), for: .normal)
        return btn
    }()
    
    lazy var switchCameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image = TUICallKitCommon.getBundleImage(name: "switch_camera") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(switchCameraTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    lazy var virtualBackgroundButton: UIButton = {
        let btn = UIButton(type: .system)
        if let image = TUICallKitCommon.getBundleImage(name: "virtual_background") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(virtualBackgroundTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(muteMicBtn)
        addSubview(changeSpeakerBtn)
        addSubview(closeCameraBtn)
        addSubview(hangupBtn)
        addSubview(switchCameraBtn)
        if TUICallState.instance.showVirtualBackgroundButton {
            addSubview(virtualBackgroundButton)
        }
    }
    
    func activateConstraints() {
        muteMicBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 110.scaleWidth() : -110.scaleWidth())
            make.centerY.equalTo(changeSpeakerBtn)
            make.size.equalTo(kControlBtnSize)
        }
        changeSpeakerBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(hangupBtn.snp.top).offset(-20.scaleHeight())
            make.size.equalTo(kControlBtnSize)
        }
        closeCameraBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -110.scaleWidth() : 110.scaleWidth())
            make.centerY.equalTo(self.changeSpeakerBtn)
            make.size.equalTo(kControlBtnSize)
        }
        hangupBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(snp.bottom)
            make.width.height.equalTo(60.scaleWidth())
        }
        switchCameraBtn.snp.makeConstraints { make in
            make.centerY.equalTo(hangupBtn)
            make.leading.equalTo(hangupBtn.snp.trailing).offset(40.scaleWidth())
            make.size.equalTo(CGSize(width: 28.scaleWidth(), height: 28.scaleWidth()))
        }
        if TUICallState.instance.showVirtualBackgroundButton {
            virtualBackgroundButton.snp.makeConstraints { make in
                make.centerY.equalTo(hangupBtn)
                make.trailing.equalTo(hangupBtn.snp.leading).offset(-40.scaleWidth())
                make.size.equalTo(CGSize(width: 28.scaleWidth(), height: 28.scaleWidth()))
            }
        }
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
            virtualBackgroundButton.isHidden = true
            switchCameraBtn.isHidden = true
        } else {
            guard let videoViewEntity = VideoFactory.instance.viewMap[TUICallState.instance.selfUser.value.id.value] else { return }
            CallEngineManager.instance.openCamera(videoView: videoViewEntity.videoView)
            virtualBackgroundButton.isHidden = false
            switchCameraBtn.isHidden = false
        }
    }
    
    func changeSpeakerEvent(sender: UIButton) {
        CallEngineManager.instance.changeSpeaker()
        updateChangeSpeakerBtn(isSpeaker: TUICallState.instance.audioDevice.value == .speakerphone)
    }
    
    @objc func hangupTouchEvent(sender: UIButton) {
        CallEngineManager.instance.hangup()
    }
    
    @objc func switchCameraTouchEvent(sender: UIButton) {
        CallEngineManager.instance.switchCamera()
    }
    
    @objc func virtualBackgroundTouchEvent(sender: UIButton) {
        CallEngineManager.instance.setBlurBackground()
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
    
    func registerObserveState() {
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateCloseCameraBtn(open: TUICallState.instance.isCameraOpen.value)
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
}
