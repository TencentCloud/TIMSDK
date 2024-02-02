//
//  VideoCallerAndCalleeAcceptedView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import SnapKit

class VideoCallerAndCalleeAcceptedView: UIView {
    
    let viewModel = VideoCallerAndCalleeAcceptedViewModel()
    
    lazy var muteMicBtn: BaseControlButton = {
        let titleKey = viewModel.isMicMute.value ? "TUICallKit.muted" : "TUICallKit.unmuted"
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: titleKey) ?? "",
                                           imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.muteMicEvent(sender: sender)
        }
        let imageName = viewModel.isMicMute.value ? "icon_mute_on" : "icon_mute"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return btn
    }()
    
    lazy var closeCameraBtn: BaseControlButton = {
        let titleKey = viewModel.isCameraOpen.value ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff"
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: titleKey) ?? "",
                                           imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.closeCameraTouchEvent(sender: sender)
        }
        let imageName = viewModel.isCameraOpen.value ? "icon_camera_on" : "icon_camera_off"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return btn
    }()
    
    lazy var changeSpeakerBtn: BaseControlButton = {
        let titleKey = (viewModel.audioDevice.value == .speakerphone) ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece"
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: titleKey) ?? "",
                                           imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.changeSpeakerEvent(sender: sender)
        }
        let imageName = (viewModel.audioDevice.value == .speakerphone) ? "icon_handsfree_on" : "icon_handsfree"
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
    }
    
    func activateConstraints() {
        muteMicBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 100.scaleWidth() : -100.scaleWidth())
            make.centerY.equalTo(changeSpeakerBtn)
            make.size.equalTo(kControlBtnSize)
        }
        changeSpeakerBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(hangupBtn.snp.top).offset(-20.scaleHeight())
            make.size.equalTo(kControlBtnSize)
        }
        closeCameraBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -100.scaleWidth() : 100.scaleWidth())
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
    }
    
    // MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        viewModel.muteMic()
        updateMuteAudioBtn(mute: viewModel.isMicMute.value == true)
    }
    
    func closeCameraTouchEvent(sender: UIButton) {
        updateCloseCameraBtn(open: viewModel.isCameraOpen.value != true)
        if viewModel.isCameraOpen.value == true {
            viewModel.closeCamera()
        } else {
            guard let videoViewEntity = VideoFactory.instance.viewMap[viewModel.selfUser.value.id.value] else { return }
            viewModel.openCamera(videoView: videoViewEntity.videoView)
        }
    }
    
    func changeSpeakerEvent(sender: UIButton) {
        viewModel.changeSpeaker()
        updateChangeSpeakerBtn(isSpeaker: viewModel.audioDevice.value == .speakerphone)
    }
    
    @objc func hangupTouchEvent(sender: UIButton) {
        viewModel.hangup()
    }
    
    @objc func switchCameraTouchEvent(sender: UIButton) {
        viewModel.switchCamera()
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
}
