//
//  AudioCallerWaitingAndAcceptedView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import UIKit
import TUICallEngine

class AudioCallerWaitingAndAcceptedView : UIView {
    
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()
    
    lazy var muteMicBtn: BaseControlButton = {
        let titleKey = TUICallState.instance.isMicMute.value ? "TUICallKit.muted" : "TUICallKit.unmuted"
        let muteAudioBtn = BaseControlButton.create(frame: CGRect.zero,
                                                    title: TUICallKitLocalize(key: titleKey) ?? "",
                                                    imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.muteMicEvent(sender: sender)
        })
        
        let imageName = TUICallState.instance.isMicMute.value ? "icon_mute_on" : "icon_mute"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            muteAudioBtn.updateImage(image: image)
        }
        muteAudioBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return muteAudioBtn
    }()
    
    lazy var hangupBtn: BaseControlButton = {
        let hangupBtn = BaseControlButton.create(frame: CGRect.zero,
                                                 title: TUICallKitLocalize(key: "TUICallKit.hangup") ?? "",
                                                 imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.hangupEvent(sender: sender)
        })
        if let image = TUICallKitCommon.getBundleImage(name: "icon_hangup") {
            hangupBtn.updateImage(image: image)
        }
        hangupBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return hangupBtn
    }()
    
    lazy var changeSpeakerBtn: BaseControlButton = {
        let titleKey = (TUICallState.instance.audioDevice.value == .speakerphone) ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece"
        let changeSpeakerBtn = BaseControlButton.create(frame: CGRect.zero,
                                                        title: TUICallKitLocalize(key: titleKey) ?? "",
                                                        imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.changeSpeakerEvent(sender: sender)
        })
        let imageName = (TUICallState.instance.audioDevice.value == .speakerphone) ? "icon_handsfree_on" : "icon_handsfree"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            changeSpeakerBtn.updateImage(image: image)
        }
        changeSpeakerBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return changeSpeakerBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.isMicMute.removeObserver(isMicMuteObserver)
        TUICallState.instance.audioDevice.removeObserver(audioDeviceObserver)
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
        addSubview(hangupBtn)
        addSubview(changeSpeakerBtn)
    }
    
    func activateConstraints() {
        muteMicBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 110.scaleWidth() : -110.scaleWidth())
            make.centerY.equalTo(hangupBtn)
            make.size.equalTo(kControlBtnSize)
        }
        hangupBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.size.equalTo(kControlBtnSize)
        }
        changeSpeakerBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -110.scaleWidth() : 110.scaleWidth())
            make.centerY.equalTo(self.hangupBtn)
            make.size.equalTo(kControlBtnSize)
        }
    }
    
    // MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        CallEngineManager.instance.muteMic()
    }
    
    func changeSpeakerEvent(sender: UIButton) {
        CallEngineManager.instance.changeSpeaker()
    }
    
    func hangupEvent(sender: UIButton) {
        CallEngineManager.instance.hangup()
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        TUICallState.instance.isMicMute.addObserver(isMicMuteObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateMuteAudioBtn(mute: newValue)
        })
        
        TUICallState.instance.audioDevice.addObserver(audioDeviceObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateChangeSpeakerBtn(isSpeaker: newValue == .speakerphone)
        })
    }
    
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
}
