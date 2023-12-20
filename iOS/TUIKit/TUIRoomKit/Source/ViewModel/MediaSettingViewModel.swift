//
//  MediaSettingViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif

protocol MediaSettingViewEventResponder: AnyObject {
    func showResolutionAlert()
    func showFrameRateAlert()
    func updateStackView(item: ListCellItemData)
    func makeToast(text: String)
}

class MediaSettingViewModel {
    private(set) var videoItems: [ListCellItemData] = []
    private(set) var audioItems: [ListCellItemData] = []
    weak var viewResponder: MediaSettingViewEventResponder? = nil
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var videoSetting: VideoModel {
        engineManager.store.videoSetting
    }
    var audioSetting: AudioModel {
        engineManager.store.audioSetting
    }
    let resolutionNameItems: [String] = [.smoothResolutionText, .standardResolutionText, .highResolutionText, .superResolutionText]
    private let resolutionItems: [TUIVideoQuality] = [.quality360P, .quality540P, .quality720P, .quality1080P]
    private let bitrateArray = [550, 850, 1_200, 2_000]
    let topItems: [String] = [.videoText, .audioText]
    let frameRateArray = ["15", "20"]
    
    init() {
        createVideoItem()
        createAudioItem()
    }
    
    private func createVideoItem() {
        let resolutionItem = ListCellItemData()
        resolutionItem.titleText = .resolutionText
        resolutionItem.hasOverAllAction = true
        resolutionItem.type = .resolutionType
        resolutionItem.hasDownLineView = true
        resolutionItem.hasRightButton = true
        let buttonData = ButtonItemData()
        if let resolutionName = getResolutionName(videoQuality: videoSetting.videoQuality) {
            buttonData.normalTitle = resolutionName
        }
        buttonData.orientation = .right
        buttonData.normalIcon = "room_down_arrow1"
        buttonData.resourceBundle = tuiRoomKitBundle()
        buttonData.titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        buttonData.titleColor = UIColor(0xD1D9EC)
        buttonData.size = CGSize(width: 80, height: 30)
        buttonData.isEnabled = false
        resolutionItem.buttonData = buttonData
        resolutionItem.action = { [weak self] sender in
            guard let self = self else { return }
            self.resolutionAction()
        }
        videoItems.append(resolutionItem)
        
        let frameRateItem = ListCellItemData()
        frameRateItem.titleText = .frameRateText
        frameRateItem.hasOverAllAction = true
        frameRateItem.type = .frameRateType
        frameRateItem.hasRightButton = true
        let frameRateButtonData = ButtonItemData()
        frameRateButtonData.orientation = .right
        frameRateButtonData.normalIcon = "room_down_arrow1"
        frameRateButtonData.normalTitle = String(videoSetting.videoFps)
        frameRateButtonData.resourceBundle = tuiRoomKitBundle()
        frameRateButtonData.titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        frameRateButtonData.titleColor = UIColor(0xD1D9EC)
        frameRateButtonData.size = CGSize(width: 80, height: 30)
        frameRateButtonData.isEnabled = false
        frameRateItem.buttonData = frameRateButtonData
        frameRateItem.action = { [weak self] sender in
            guard let self = self else { return }
            self.frameRateAction()
        }
        videoItems.append(frameRateItem)
    }
    
    private func createAudioItem() {
        let captureVolumeItem = ListCellItemData()
        captureVolumeItem.titleText = .captureVolumeText
        captureVolumeItem.hasSlider = true
        captureVolumeItem.hasSliderLabel = true
        captureVolumeItem.minimumValue = 0
        captureVolumeItem.maximumValue = 100
        captureVolumeItem.sliderStep = 1
        captureVolumeItem.sliderDefault = Float(audioSetting.captureVolume)
        captureVolumeItem.type = .captureVolumeType
        captureVolumeItem.hasDownLineView = true
        captureVolumeItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISlider else { return }
            self.captureVolumeAction(sender: view)
        }
        audioItems.append(captureVolumeItem)
        
        let playingVolumeItem = ListCellItemData()
        playingVolumeItem.titleText = .playVolumeText
        playingVolumeItem.hasSlider = true
        playingVolumeItem.hasSliderLabel = true
        playingVolumeItem.minimumValue = 0
        playingVolumeItem.maximumValue = 100
        playingVolumeItem.sliderStep = 1
        playingVolumeItem.sliderDefault = Float(audioSetting.playVolume)
        playingVolumeItem.type = .playingVolumeType
        playingVolumeItem.hasDownLineView = true
        playingVolumeItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISlider else { return }
            self.playingVolumeAction(sender: view)
        }
        audioItems.append(playingVolumeItem)
        
        let volumePromptItem = ListCellItemData()
        volumePromptItem.titleText = .volumePromptText
        volumePromptItem.hasSwitch = true
        volumePromptItem.isSwitchOn = audioSetting.volumePrompt
        volumePromptItem.type = .volumePromptType
        volumePromptItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.volumePromptAction(sender: view)
        }
        audioItems.append(volumePromptItem)
    }
    
    private func resolutionAction() {
        viewResponder?.showResolutionAlert()
    }
    
    private func updateVideoBitrateEncoderParam() {
        guard let bitrate = getBitrate(videoQuality: videoSetting.videoQuality) else { return }
        videoSetting.videoBitrate = bitrate
        let param = TRTCVideoEncParam()
        param.videoBitrate = Int32(videoSetting.videoBitrate)
        param.enableAdjustRes = true
        engineManager.setVideoEncoderParam(param)
    }
    
    private func updateVideoFpsEncoderParam() {
        let param = TRTCVideoEncParam()
        param.videoFps = Int32(videoSetting.videoFps)
        param.enableAdjustRes = true
        engineManager.setVideoEncoderParam(param)
    }
    
    private func frameRateAction() {
        viewResponder?.showFrameRateAlert()
    }
    
    private func captureVolumeAction(sender: UISlider) {
        engineManager.setAudioCaptureVolume(Int(sender.value))
    }
    
    private func playingVolumeAction(sender: UISlider) {
        engineManager.setAudioPlayoutVolume(Int(sender.value))
    }
    
    private func volumePromptAction(sender: UISwitch) {
        engineManager.enableAudioVolumeEvaluation(isVolumePrompt: sender.isOn)
    }
    
    func changeResolutionAction(index: Int) {
        guard let videoItem = videoItems.first(where: { $0.type == .resolutionType }) else { return }
        guard let quality = resolutionItems[safe: index] else { return }
        guard let resolutionName = getResolutionName(videoQuality: quality) else { return }
        videoSetting.videoQuality = quality
        videoItem.buttonData?.normalTitle = resolutionName
        viewResponder?.updateStackView(item: videoItem)
        engineManager.updateVideoQuality(quality: videoSetting.videoQuality)
        updateVideoBitrateEncoderParam()
    }
    
    func changeFrameRateAction(index: Int) {
        guard let videoItem = videoItems.first(where: { $0.type == .frameRateType }) else { return }
        guard let frameRate = frameRateArray[safe: index] else { return }
        videoItem.buttonData?.normalTitle = frameRate
        viewResponder?.updateStackView(item: videoItem)
        videoSetting.videoFps = Int(frameRate) ?? videoSetting.videoFps
        updateVideoFpsEncoderParam()
    }
    
    func getCurrentResolutionIndex() -> Int {
        guard let index = resolutionItems.firstIndex(where: { $0 == videoSetting.videoQuality }) else { return 0 }
        return index
    }
    
    func getCurrentFrameRateIndex() -> Int {
        let frameRateString = String(videoSetting.videoFps)
        guard let index = frameRateArray.firstIndex(where: { $0 == frameRateString }) else { return 0 }
        return index
    }
    
    private func getResolutionName(videoQuality: TUIVideoQuality) -> String? {
        guard let index = resolutionItems.firstIndex(of: videoQuality) else { return nil }
        guard let resolutionName = resolutionNameItems[safe: index] else { return nil }
        return resolutionName
    }
    
    private func getBitrate(videoQuality: TUIVideoQuality) -> Int? {
        guard let index = resolutionItems.firstIndex(of: videoQuality) else { return nil }
        guard let bitrate = bitrateArray[safe: index] else { return nil }
        return bitrate
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var videoText: String {
        localized("TUIRoom.video.settings")
    }
    static var audioText: String {
        localized("TUIRoom.audio.settings")
    }
    static var versionLowToastText: String {
        localized("TUIRoom.version.too.low")
    }
    static var resolutionText: String {
        localized("TUIRoom.resolution")
    }
    static var frameRateText: String {
        localized("TUIRoom.frame.rate")
    }
    static var bitrateText: String {
        localized("TUIRoom.bitrate")
    }
    static var localMirrorText: String {
        localized("TUIRoom.local.mirror")
    }
    static var captureVolumeText: String {
        localized("TUIRoom.capture.volume")
    }
    static var playVolumeText: String {
        localized("TUIRoom.play.volume")
    }
    static var volumePromptText: String {
        localized("TUIRoom.volume.prompt")
    }
    static var audioRecordingText: String {
        localized("TUIRoom.audio.recording")
    }
    static var smoothResolutionText: String {
        localized("TUIRoom.smooth.resolution")
    }
    static var standardResolutionText: String {
        localized("TUIRoom.standard.resolution")
    }
    static var highResolutionText: String {
        localized("TUIRoom.high.resolution")
    }
    static var superResolutionText: String {
        localized("TUIRoom.super.resolution")
    }
}
