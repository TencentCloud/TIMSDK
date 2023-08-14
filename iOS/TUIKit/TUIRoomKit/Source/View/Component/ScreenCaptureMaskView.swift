//
//  ScreenCaptureMaskView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/7/17.
//  开启屏幕共享的蒙层View
//

import Foundation

class ScreenCaptureMaskView: UIView {
    let sharingScreenLabel: UILabel = {
        let label = UILabel()
        label.text = .sharingScreenText
        label.textColor = .white
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "PingFangSC-Regular", size: 18)
        return label
    }()
    
    let stopScreenButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .red
        button.setTitle(.stopShareScreen, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isEnabled = true
        button.layer.cornerRadius = 12
        return button
    }()
    
    let screenRecordingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .black
        label.text = .screenRecordingText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont(name: "PingFangSC-Regular", size: 18)
        return label
    }()
    
    // MARK: - view layout
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        backgroundColor = UIColor(0x1B1E26)
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    private func constructViewHierarchy() {
        addSubview(sharingScreenLabel)
        addSubview(stopScreenButton)
        addSubview(screenRecordingLabel)
    }
    
    private func activateConstraints() {
        sharingScreenLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
        }
        stopScreenButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(100)
            make.centerY.equalToSuperview().offset(40)
        }
        screenRecordingLabel.snp.makeConstraints { make in
            make.top.equalTo(sharingScreenLabel)
            make.right.equalTo(safeAreaLayoutGuide.snp.right)
            make.width.equalTo(30)
            make.height.equalTo(150)
        }
    }
    
    private func bindInteraction() {
        stopScreenButton.addTarget(self, action: #selector(stopScreenCaptureAction(sender:)), for: .touchUpInside)
    }
    
    @objc func stopScreenCaptureAction(sender: UIButton) {
        EngineManager.createInstance().roomEngine.stopScreenCapture()
        ScreenCaptureMaskView.dismiss()
    }
    
    class func show() {
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let currentWindow = RoomRouter.getCurrentWindow()
        currentWindow?.addSubview(ScreenCaptureMaskView(frame: frame))
    }
    
    class func dismiss() {
        guard let currentWindow = RoomRouter.getCurrentWindow() else { return }
        for view in currentWindow.subviews where view is ScreenCaptureMaskView {
            view.removeFromSuperview()
        }
    }
}

private extension String {
    static var sharingScreenText: String {
        localized("TUIRoom.sharing.screen")
    }
    static var stopShareScreen: String {
        localized("TUIRoom.stop.share.screen")
    }
    static var screenRecordingText: String {
        localized("TUIRoom.screen.recording")
    }
}
