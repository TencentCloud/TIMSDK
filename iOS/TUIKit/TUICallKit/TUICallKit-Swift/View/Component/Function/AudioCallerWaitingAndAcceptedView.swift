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
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()
        
    lazy var muteMicBtn: BaseControlButton = {
        weak var weakSelf = self
        let muteAudioBtn = BaseControlButton.create(frame: CGRect.zero,
                                                 title: TUICallKitLocalize(key: "Demo.TRTC.Calling.mic") ?? "" ,
                                                 imageSize: kBtnSmallSize, buttonAction: { sender in
            weakSelf?.muteMicEvent(sender: sender)
        })
        if let image = TUICallKitCommon.getBundleImage(name: "ic_mute") {
            muteAudioBtn.updateImage(image: image)
        }
        muteAudioBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#242424"))
        return muteAudioBtn
    }()
    
    lazy var hangupBtn: BaseControlButton = {
        weak var weakSelf = self
        let hangupBtn = BaseControlButton.create(frame: CGRect.zero,
                                                 title: TUICallKitLocalize(key: "Demo.TRTC.Calling.hangup") ?? "" ,
                                                 imageSize: kBtnLargeSize, buttonAction: { sender in
            weakSelf?.hanguphEvent(sender: sender)
        })
        if let image = TUICallKitCommon.getBundleImage(name: "ic_hangup") {
            hangupBtn.updateImage(image: image)
        }
        hangupBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#242424"))
        return hangupBtn
    }()
    
    lazy var changeSpeakerBtn: BaseControlButton = {
        weak var weakSelf = self
        let changeSpeakerBtn = BaseControlButton.create(frame: CGRect.zero,
                                                        title: TUICallKitLocalize(key: "Demo.TRTC.Calling.speaker") ?? "" ,
                                                        imageSize: kBtnSmallSize, buttonAction: { sender in
            weakSelf?.changeSpeakerEvent(sender: sender)
        })
        if let image = TUICallKitCommon.getBundleImage(name: "ic_handsfree") {
            changeSpeakerBtn.updateImage(image: image)
        }
        changeSpeakerBtn.updateTitleColor(titleColor: UIColor.t_colorWithHexString(color: "#242424"))
        return changeSpeakerBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.audioDevice.removeObserver(audioDeviceObserver)
        viewModel.isMicMute.removeObserver(isMicMuteObserver)
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
        addSubview(muteMicBtn)
        addSubview(hangupBtn)
        addSubview(changeSpeakerBtn)
    }

    func activateConstraints() {
        muteMicBtn.snp.makeConstraints { make in
            make.trailing.equalTo(hangupBtn.snp.leading).offset(-5)
            make.centerY.equalTo(hangupBtn)
            make.size.equalTo(kControlBtnSize)
        }
        
        hangupBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.size.equalTo(kControlBtnSize)
        }
        
        changeSpeakerBtn.snp.makeConstraints { make in
            make.leading.equalTo(self.hangupBtn.snp.trailing).offset(5)
            make.centerY.equalTo(self.hangupBtn)
            make.size.equalTo(kControlBtnSize)
        }
    }

    //MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        viewModel.muteMic()
        updateMuteAudioBtn(mute: viewModel.isMicMute.value == true)
    }
    
    func changeSpeakerEvent(sender: UIButton) {
        viewModel.changeSpeaker()
        updateChangeSpeakerBtn(isSpeaker: viewModel.audioDevice.value == .speakerphone)
    }
    
    func hanguphEvent(sender: UIButton) {
        viewModel.hangup()
    }
    
    //MARK: Update UI
    func updateMuteAudioBtn(mute: Bool) {
        if let image = TUICallKitCommon.getBundleImage(name: mute ? "ic_mute_on" : "ic_mute") {
            muteMicBtn.updateImage(image: image)
        }
    }
    
    func updateChangeSpeakerBtn(isSpeaker: Bool) {
        if let image = TUICallKitCommon.getBundleImage(name: isSpeaker ? "ic_handsfree_on" : "ic_handsfree") {
            changeSpeakerBtn.updateImage(image: image)
        }
    }
}
