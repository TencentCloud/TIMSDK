//
//  VideoCallerWaitingView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation

class VideoCallerWaitingView: UIView {
    
    let viewModel = VideoCallerWaitingViewModel()
    
    lazy var hangupBtn: BaseControlButton = {
        weak var weakSelf = self
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: "TUICallKit.hangup") ?? "",
                                           imageSize: kBtnLargeSize) { sender in
            weakSelf?.hangupTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "icon_hangup") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return btn
    }()
    
    let switchCameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image = TUICallKitCommon.getBundleImage(name: "switch_camera") {
            btn.setBackgroundImage(image, for: .normal)
        }
        return btn
    }()
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(hangupBtn)
        addSubview(switchCameraBtn)
    }
    
    func activateConstraints() {
        hangupBtn.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(kControlBtnSize)
        }
        switchCameraBtn.snp.makeConstraints { make in
            make.centerY.equalTo(hangupBtn)
            make.leading.equalTo(hangupBtn.snp.trailing).offset(40.scaleWidth())
            make.size.equalTo(CGSize(width: 28.scaleWidth(), height: 28.scaleWidth()))
        }
    }
    
    func bindInteraction() {
        switchCameraBtn.addTarget(self, action: #selector(switchCameraTouchEvent(sender: )), for: .touchUpInside)
    }
    
    // MARK: Action Event
    func hangupTouchEvent(sender: UIButton) {
        viewModel.hangup()
    }
    
    @objc func switchCameraTouchEvent(sender: UIButton ) {
        viewModel.switchCamera()
    }
    
}
