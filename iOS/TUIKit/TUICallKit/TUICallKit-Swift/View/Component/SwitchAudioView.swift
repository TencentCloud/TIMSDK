//
//  SwitchAudioView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation

class SwitchAudioView: UIView {
    
    let viewModel = SwitchAudioViewModel()
    lazy var switchToAudioBtn: BaseControlButton = {
        weak var weakSelf = self
        let switchToAudioBtn = BaseControlButton.create(frame: CGRect.zero,
                                                        title: TUICallKitLocalize(key: "Demo.TRTC.Calling.switchtoaudio") ?? "",
                                                        imageSize: CGSize(width: 28,height: 18)) { sender in
            weakSelf?.switchToAudioTouchAudio(sender: sender)
        }
        if let image = TUICallKitCommon.getBundleImage(name: "switch2audio") {
            switchToAudioBtn.updateImage(image: image)
        }
        switchToAudioBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#F2F2F2"))
        return switchToAudioBtn
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
        isViewReady = true
    }

    func constructViewHierarchy() {
        addSubview(self.switchToAudioBtn)
    }

    func activateConstraints() {
        switchToAudioBtn.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: 200, height: 42))
        }
    }

    //MARK: Action Event
    func switchToAudioTouchAudio(sender: UIButton) {
        viewModel.switchToAudio()
    }
}
