//
//  VideoCallerWaitingView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation

class VideoCallerWaitingView: UIView {
    
    let viewModel = FunctionViewModel()
    lazy var hangupBtn: BaseControlButton = {
        weak var weakSelf = self
        let btn = BaseControlButton.create(frame: CGRect.zero,
                                           title: TUICallKitLocalize(key: "Demo.TRTC.Calling.hangup") ?? "",
                                           imageSize: kBtnLargeSize) { sender in
            weakSelf?.hangupTouchEvent(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "ic_hangup") {
            btn.updateImage(image: image)
        }
        btn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
        return btn
    }()
    
    let switchCameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image = TUICallKitCommon.getBundleImage(name: "switch_camera") {
            btn.setBackgroundImage(image, for: .normal)
        }
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI Specification Processing
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
            make.leading.equalTo(hangupBtn.snp.trailing).offset(20)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
    }
    
    func bindInteraction() {
        switchCameraBtn.addTarget(self, action: #selector(switchCameraTouchEvent(sender: )), for: .touchUpInside)
    }
    
    //MARK: Action Event
    func hangupTouchEvent(sender: UIButton) {
        viewModel.hangup()
    }
    
    @objc func switchCameraTouchEvent(sender: UIButton ) {
        viewModel.switchCamera()
    }
    
}
