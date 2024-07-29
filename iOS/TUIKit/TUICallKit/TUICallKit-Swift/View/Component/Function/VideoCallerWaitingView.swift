//
//  VideoCallerWaitingView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation

class VideoCallerWaitingView: UIView {
    
    let enableBlurBackgroundObserver = Observer()
    
    lazy var switchCameraBtn: BaseControlButton = {
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: "TUICallKit.switchCamera") ?? "",
                                           imageSize: kBtnLargeSize) {  [weak self] sender in
            guard let self = self else { return }
            self.switchCameraTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "icon_big_switch_camera") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return btn
    }()
    
    lazy var virtualBackgroundButton: BaseControlButton = {
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: "TUICallKit.blurBackground") ?? "",
                                           imageSize: kBtnLargeSize) { [weak self] sender in
            guard let self = self else { return }
            self.virtualBackgroundTouchEvent(sender: sender)
        }
        let imageName = TUICallState.instance.enableBlurBackground.value ? "icon_big_virtual_background_on" : "icon_big_virtual_background_off"
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
    
    lazy var hangupBtn: BaseControlButton = {
        weak var weakSelf = self
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: "TUICallKit.hangup") ?? "",
                                           imageSize: kBtnLargeSize) { [weak self] sender in
            guard let self = self else { return }
            self.hangupTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "icon_hangup") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
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
        if TUICallState.instance.showVirtualBackgroundButton {
            TUICallState.instance.selfUser.removeObserver(enableBlurBackgroundObserver)
        }
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
        addSubview(switchCameraBtn)
        addSubview(closeCameraBtn)
        addSubview(hangupBtn)
        if TUICallState.instance.showVirtualBackgroundButton {
            addSubview(virtualBackgroundButton)
        }
    }
    
    func activateConstraints() {
        if TUICallState.instance.showVirtualBackgroundButton {
            virtualBackgroundButton.snp.makeConstraints { make in
                make.top.centerX.equalTo(self)
                make.bottom.equalTo(hangupBtn.snp.top).offset(-8.scaleWidth())
                make.size.equalTo(kControlBtnSize)
            }
        }
        switchCameraBtn.snp.makeConstraints { make in
            make.centerY.equalTo(TUICallState.instance.showVirtualBackgroundButton ? virtualBackgroundButton : hangupBtn)
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 110.scaleWidth() : -110.scaleWidth())
            make.size.equalTo(kControlBtnSize)
        }
        hangupBtn.snp.makeConstraints { make in
            if !TUICallState.instance.showVirtualBackgroundButton {
                make.top.equalTo(self)
            }
            make.centerX.bottom.equalTo(self)
            make.size.equalTo(kControlBtnSize)
        }
        closeCameraBtn.snp.makeConstraints { make in
            make.centerY.equalTo(TUICallState.instance.showVirtualBackgroundButton ? virtualBackgroundButton : hangupBtn)
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -110.scaleWidth() : 110.scaleWidth())
            make.size.equalTo(kControlBtnSize)
        }
    }
    
    // MARK: Action Event
    func closeCameraTouchEvent(sender: UIButton) {
        updateCloseCameraBtn(open: TUICallState.instance.isCameraOpen.value != true)
        if TUICallState.instance.isCameraOpen.value == true {
            CallEngineManager.instance.closeCamera()
            virtualBackgroundButton.button.isEnabled = false
            switchCameraBtn.button.isEnabled = false
        } else {
            guard let videoViewEntity = VideoFactory.instance.viewMap[TUICallState.instance.selfUser.value.id.value] else { return }
            CallEngineManager.instance.openCamera(videoView: videoViewEntity.videoView)
            virtualBackgroundButton.button.isEnabled = true
            switchCameraBtn.button.isEnabled = true
        }
    }
    
    func updateCloseCameraBtn(open: Bool) {
        closeCameraBtn.updateTitle(title: TUICallKitLocalize(key: open ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff") ?? "")
        
        if let image = TUICallKitCommon.getBundleImage(name: open ? "icon_camera_on" : "icon_camera_off") {
            closeCameraBtn.updateImage(image: image)
        }
    }
    
    func hangupTouchEvent(sender: UIButton) {
        CallEngineManager.instance.hangup()
    }
    
    func switchCameraTouchEvent(sender: UIButton ) {
        CallEngineManager.instance.switchCamera()
    }
    
    func virtualBackgroundTouchEvent(sender: UIButton) {
        CallEngineManager.instance.setBlurBackground()
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        if TUICallState.instance.showVirtualBackgroundButton {
            TUICallState.instance.enableBlurBackground.addObserver(enableBlurBackgroundObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.updateVirtualBackgroundButton()
            })
        }
    }
    
    func updateVirtualBackgroundButton() {
        let imageName = TUICallState.instance.enableBlurBackground.value ? "icon_big_virtual_background_on" : "icon_big_virtual_background_off"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            virtualBackgroundButton.updateImage(image: image)
        }
    }
    
}
