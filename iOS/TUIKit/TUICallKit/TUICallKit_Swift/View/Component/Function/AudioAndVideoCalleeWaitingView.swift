//
//  AudioAndVideoCalleeWaitingView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import RTCRoomEngine
import RTCCommon

class AudioAndVideoCalleeWaitingView: UIView {
    
    private lazy var acceptBtn: UIView = {
        let acceptBtn = FeatureButton.create(title: TUICallKitLocalize(key: "TUICallKit.answer"),
                                             titleColor: Color_White,
                                             image: CallKitBundle.getBundleImage(name: "icon_dialing"),
                                             imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.acceptTouchEvent(sender: sender)
        }
        return acceptBtn
    }()
    
    private lazy var rejectBtn: UIView = {
        let rejectBtn = FeatureButton.create(title: TUICallKitLocalize(key: "TUICallKit.decline"),
                                             titleColor: Color_White,
                                             image: CallKitBundle.getBundleImage(name: "icon_hangup"),
                                             imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.rejectTouchEvent(sender: sender)
        }
        return rejectBtn
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
        addSubview(rejectBtn)
        addSubview(acceptBtn)
    }
    
    func activateConstraints() {
        rejectBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rejectBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: TUICoreDefineConvert.getIsRTL() ? 80.scale375Width() : -80.scale375Width()),
            rejectBtn.topAnchor.constraint(equalTo: self.topAnchor),
            rejectBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            rejectBtn.widthAnchor.constraint(equalToConstant: kControlBtnSize.width),
            rejectBtn.heightAnchor.constraint(equalToConstant: kControlBtnSize.height)
        ])

        acceptBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            acceptBtn.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: TUICoreDefineConvert.getIsRTL() ? -80.scale375Width() : 80.scale375Width()),
            acceptBtn.topAnchor.constraint(equalTo: self.topAnchor),
            acceptBtn.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            acceptBtn.widthAnchor.constraint(equalToConstant: kControlBtnSize.width),
            acceptBtn.heightAnchor.constraint(equalToConstant: kControlBtnSize.height)
        ])

    }
    
    // MARK: Event Action
    func rejectTouchEvent(sender: UIButton) {
        CallManager.shared.reject() { } fail: { code, message in }
    }
    
    func acceptTouchEvent(sender: UIButton) {
        CallManager.shared.accept() { } fail: { code, message in }
    }
}
