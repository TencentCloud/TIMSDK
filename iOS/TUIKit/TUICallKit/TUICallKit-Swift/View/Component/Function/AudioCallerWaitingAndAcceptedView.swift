//
//  AudioCallerWaitingAndAcceptedView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import UIKit

class AudioCallerWaitingAndAcceptedView : UIView {
    
    let viewModel = AudioCallerWaitingAndAcceptedViewModel()
    
    lazy var muteMicBtn: BaseControlButton = {
        let titleKey = viewModel.isMicMute.value ? "TUICallKit.muted" : "TUICallKit.unmuted"
        let muteAudioBtn = BaseControlButton.create(frame: CGRect.zero,
                                                    title: TUICallKitLocalize(key: titleKey) ?? "",
                                                    imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.muteMicEvent(sender: sender)
        })
        
        let imageName = viewModel.isMicMute.value ? "icon_mute_on" : "icon_mute"
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
        let titleKey = (viewModel.audioDevice.value == .speakerphone) ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece"
        let changeSpeakerBtn = BaseControlButton.create(frame: CGRect.zero,
                                                        title: TUICallKitLocalize(key: titleKey) ?? "",
                                                        imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.changeSpeakerEvent(sender: sender)
        })
        let imageName = (viewModel.audioDevice.value == .speakerphone) ? "icon_handsfree_on" : "icon_handsfree"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            changeSpeakerBtn.updateImage(image: image)
        }
        changeSpeakerBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#D5E0F2"))
        return changeSpeakerBtn
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
        addSubview(hangupBtn)
        addSubview(changeSpeakerBtn)
    }
    
    func activateConstraints() {
        muteMicBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 100.scaleWidth() : -100.scaleWidth())
            make.centerY.equalTo(hangupBtn)
            make.size.equalTo(kControlBtnSize)
        }
        hangupBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.size.equalTo(kControlBtnSize)
        }
        changeSpeakerBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -100.scaleWidth() : 100.scaleWidth())
            make.centerY.equalTo(self.hangupBtn)
            make.size.equalTo(kControlBtnSize)
        }
    }
    
    // MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        viewModel.muteMic()
        updateMuteAudioBtn(mute: viewModel.isMicMute.value == true)
    }
    
    func changeSpeakerEvent(sender: UIButton) {
        viewModel.changeSpeaker()
        updateChangeSpeakerBtn(isSpeaker: viewModel.audioDevice.value == .speakerphone)
    }
    
    func hangupEvent(sender: UIButton) {
        viewModel.hangup()
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
}
