//
//  RoomTypeView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/14.
//

import Foundation
import UIKit
import Factory

class RoomTypeView: UIView {
    var dismissAction: (() -> Void)?
    
    let freedomButton: UIButton = {
        let button = UIButton()
        button.setTitle(.freedomSpeakText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(0x22262E), for: .normal)
        button.backgroundColor = UIColor(0xFFFFFF)
        return button
    }()
    
    let raiseHandButton: UIButton = {
        let button = UIButton()
        button.setTitle(.raiseHandSpeakText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(0x22262E), for: .normal)
        button.backgroundColor = UIColor(0xFFFFFF)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(.cancelText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(UIColor(0x22262E), for: .normal)
        button.backgroundColor = UIColor(0xFFFFFF)
        return button
    }()
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(freedomButton)
        addSubview(raiseHandButton)
        addSubview(cancelButton)
    }
    
    func activateConstraints() {
        freedomButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(raiseHandButton.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58.scale375Height())
        }
        raiseHandButton.snp.makeConstraints { make in
            make.bottom.equalTo(cancelButton.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(58.scale375Height())
        }
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(97.scale375Height())
        }
    }
    
    func bindInteraction() {
        layer.cornerRadius = 12
        freedomButton.addTarget(self, action: #selector(freedomAction(sender:)), for: .touchUpInside)
        raiseHandButton.addTarget(self, action: #selector(raiseHandAction(sender:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelAction(sender:)), for: .touchUpInside)
    }
    
    @objc func freedomAction(sender: UIButton) {
        var conferenceInfo = store.conferenceInfo
        conferenceInfo.basicInfo.isSeatEnabled = false
        store.update(conference: conferenceInfo)
        dismissAction?()
    }
    
    @objc func raiseHandAction(sender: UIButton) {
        var conferenceInfo = store.conferenceInfo
        conferenceInfo.basicInfo.isSeatEnabled = true
        store.update(conference: conferenceInfo)
        dismissAction?()
    }
    
    @objc func cancelAction(sender: UIButton) {
        dismissAction?()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    @Injected(\.modifyScheduleStore) var store: ScheduleConferenceStore
}

private extension String {
    static var raiseHandSpeakText: String {
        localized("On-stage Speech Room")
    }
    static var freedomSpeakText: String {
        localized("Free Speech Room")
    }
    static var cancelText: String {
        localized("Cancel")
    }
}

