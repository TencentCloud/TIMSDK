//
//  VideoCallerWaitingView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import RTCCommon

class VideoCallerWaitingView: UIView {
    let enableBlurBackgroundObserver = Observer()
    
    private lazy var switchCameraBtn: UIView = {
        let btn = FeatureButton.create(title: TUICallKitLocalize(key: "TUICallKit.switchCamera"),
                                       titleColor: Color_White,
                                       image: CallKitBundle.getBundleImage(name: "icon_big_switch_camera"),
                                       imageSize: kBtnLargeSize) { [weak self] sender in
            guard let self = self else { return }
            self.switchCameraTouchEvent(sender: sender)
        }
        return btn
    }()
    
    private lazy var virtualBackgroundButton: UIView = {
        let imageName = CallManager.shared.viewState.isVirtualBackgroundOpened.value ? "icon_big_virtual_background_on" : "icon_big_virtual_background_off"

        let btn = FeatureButton.create(title: TUICallKitLocalize(key: "TUICallKit.blurBackground"),
                                       titleColor: Color_White,
                                       image: CallKitBundle.getBundleImage(name: imageName),
                                       imageSize: kBtnLargeSize) { [weak self] sender in
            guard let self = self else { return }
            self.virtualBackgroundTouchEvent(sender: sender)
        }
        return btn
    }()
    
    private lazy var closeCameraBtn: UIView = {
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
    
    private lazy var hangupBtn: UIView = {
        let btn = FeatureButton.create(title: nil,
                                       titleColor: Color_White,
                                       image: CallKitBundle.getBundleImage(name: "icon_hangup"),
                                       imageSize: kBtnLargeSize) { [weak self] sender in
            guard let self = self else { return }
            self.hangupTouchEvent(sender: sender)
        }
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
        if CallManager.shared.globalState.enableVirtualBackground {
            CallManager.shared.viewState.isVirtualBackgroundOpened.removeObserver(enableBlurBackgroundObserver)
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
        if CallManager.shared.globalState.enableVirtualBackground {
            addSubview(virtualBackgroundButton)
        }
    }
    
    func activateConstraints() {
        if CallManager.shared.globalState.enableVirtualBackground {
            virtualBackgroundButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                virtualBackgroundButton.topAnchor.constraint(equalTo: self.topAnchor),
                virtualBackgroundButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                virtualBackgroundButton.bottomAnchor.constraint(equalTo: hangupBtn.topAnchor, constant: -8.scale375Width()),
                virtualBackgroundButton.widthAnchor.constraint(equalToConstant: kControlBtnSize.width),
                virtualBackgroundButton.heightAnchor.constraint(equalToConstant: kControlBtnSize.height)
            ])
        }

        switchCameraBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            switchCameraBtn.centerYAnchor.constraint(equalTo: (CallManager.shared.globalState.enableVirtualBackground ? virtualBackgroundButton : hangupBtn).centerYAnchor),
            switchCameraBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: TUICoreDefineConvert.getIsRTL() ? 110.scale375Width() : -110.scale375Width()),
            switchCameraBtn.widthAnchor.constraint(equalToConstant: kControlBtnSize.width),
            switchCameraBtn.heightAnchor.constraint(equalToConstant: kControlBtnSize.height)
        ])

        hangupBtn.translatesAutoresizingMaskIntoConstraints = false
        if !CallManager.shared.globalState.enableVirtualBackground {
                NSLayoutConstraint.activate([
                    hangupBtn.topAnchor.constraint(equalTo: self.topAnchor)
                ])
            }
        NSLayoutConstraint.activate([
            hangupBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            hangupBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            hangupBtn.widthAnchor.constraint(equalToConstant: kControlBtnSize.width),
            hangupBtn.heightAnchor.constraint(equalToConstant: kControlBtnSize.height)
        ])
        

        closeCameraBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeCameraBtn.centerYAnchor.constraint(equalTo: (CallManager.shared.globalState.enableVirtualBackground ? virtualBackgroundButton : hangupBtn).centerYAnchor),
            closeCameraBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: TUICoreDefineConvert.getIsRTL() ? -110.scale375Width() : 110.scale375Width()),
            closeCameraBtn.widthAnchor.constraint(equalToConstant: kControlBtnSize.width),
            closeCameraBtn.heightAnchor.constraint(equalToConstant: kControlBtnSize.height)
        ])
    }
    
    // MARK: Action Event

    func closeCameraTouchEvent(sender: UIButton) {
        updateCloseCameraBtn(open: CallManager.shared.mediaState.isCameraOpened.value != true)
        if CallManager.shared.mediaState.isCameraOpened.value == true {
            CallManager.shared.closeCamera()
            
            (virtualBackgroundButton as? FeatureButton)?.button.isEnabled = false
            (switchCameraBtn as? FeatureButton)?.button.isEnabled = false
        } else {
            guard let videoViewEntity = VideoFactory.shared.createVideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: false) else {
                return
            }
            CallManager.shared.openCamera(videoView: videoViewEntity.getVideoView()) { } fail: { code, message in }
            
            (virtualBackgroundButton as? FeatureButton)?.button.isEnabled = true
            (switchCameraBtn as? FeatureButton)?.button.isEnabled = true
        }
    }
    
    func updateCloseCameraBtn(open: Bool) {
        (closeCameraBtn as? FeatureButton)?.updateTitle(title: TUICallKitLocalize(key: open ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff") ?? "")
        
        if let image = CallKitBundle.getBundleImage(name: open ? "icon_camera_on" : "icon_camera_off") {
            (closeCameraBtn as? FeatureButton)?.updateImage(image: image)
        }
    }
    
    func hangupTouchEvent(sender: UIButton) {
        CallManager.shared.hangup() { } fail: { code, message in }
    }
    
    func switchCameraTouchEvent(sender: UIButton) {
        CallManager.shared.switchCamera()
    }
    
    func virtualBackgroundTouchEvent(sender: UIButton) {
        CallManager.shared.setBlurBackground(enable: CallManager.shared.viewState.isVirtualBackgroundOpened.value ? false : true) 
    }
    
    // MARK: Register TUICallState Observer && Update UI

    func registerObserveState() {
        if CallManager.shared.globalState.enableVirtualBackground {
            CallManager.shared.viewState.isVirtualBackgroundOpened.addObserver(enableBlurBackgroundObserver, closure: { [weak self] _, _ in
                guard let self = self else { return }
                self.updateVirtualBackgroundButton()
            })
        }
    }
    
    func updateVirtualBackgroundButton() {
        let imageName = CallManager.shared.viewState.isVirtualBackgroundOpened.value ? "icon_big_virtual_background_on" : "icon_big_virtual_background_off"
        if let image = CallKitBundle.getBundleImage(name: imageName) {
            (virtualBackgroundButton as? FeatureButton)?.updateImage(image: image)
        }
    }
}
