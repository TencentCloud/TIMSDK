//
//  FloatingWindowStatusView.swift
//  TUICallKit
//
//  Created by noah on 2023/11/20.
//

import Foundation

class FloatingWindowGroupStatusView: UIView {
    
    let isCameraOpenObserver = Observer()
    let isMicMuteObserver = Observer()
    
    let videoImageView: UIImageView = {
        let imageView = UIImageView()
        let imageName = TUICallState.instance.isCameraOpen.value ? "icon_float_group_video_on" : "icon_float_group_video_off"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            imageView.image = image
        }
        return imageView
    }()
    
    let audioImageView: UIImageView = {
        let imageView = UIImageView()
        let imageName = TUICallState.instance.isMicMute.value ? "icon_float_group_audio_off" : "icon_float_group_audio_on"
        if let image = TUICallKitCommon.getBundleImage(name: imageName) {
            imageView.image = image
        }
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserveState()
        constructViewHierarchy()
        activateConstraints()
        backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_group_status_view_bg_color",
                                                                         defaultHex:  "#F9F6F4")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.isMicMute.removeObserver(isMicMuteObserver)
    }
    
    func constructViewHierarchy() {
        addSubview(videoImageView)
        addSubview(audioImageView)
    }
    
    func activateConstraints() {
        videoImageView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(14.scaleWidth())
            make.width.height.equalTo(16.scaleWidth())
        }
        audioImageView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.trailing.equalTo(self).offset(-14.scaleWidth())
            make.width.height.equalTo(16.scaleWidth())
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        isCameraOpenChange()
        isMicMuteChange()
    }
    
    func isCameraOpenChange() {
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver, closure: {  [weak self] newValue, _ in
            guard let self = self else { return }
            let imageName = newValue ? "icon_float_group_video_on" : "icon_float_group_video_off"
            if let image = TUICallKitCommon.getBundleImage(name: imageName) {
                self.videoImageView.image = image
            }
            
        })
    }
    
    func isMicMuteChange() {
        TUICallState.instance.isMicMute.addObserver(isMicMuteObserver, closure: {  [weak self] newValue, _ in
            guard let self = self else { return }
            let imageName = newValue ? "icon_float_group_audio_off" : "icon_float_group_audio_on"
            if let image = TUICallKitCommon.getBundleImage(name: imageName) {
                self.audioImageView.image = image
            }
        })
    }
    
}
