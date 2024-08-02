//
//  MediaSettingViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine
#if canImport(TXLiteAVSDK_TRTC)
    import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
    import TXLiteAVSDK_Professional
#endif

protocol MediaSettingViewEventResponder: AnyObject {
    func showResolutionAlert()
    func showFrameRateAlert()
    func showQualityView()
    func updateStackView(item: ListCellItemData)
    func makeToast(text: String)
}

class MediaSettingViewModel {
    private(set) var videoItems: [ListCellItemData] = []
    private(set) var audioItems: [ListCellItemData] = []
    private(set) var otherItems: [ListCellItemData] = []
    weak var viewResponder: MediaSettingViewEventResponder? = nil
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var store: RoomStore {
        engineManager.store
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
    let topItems: [String] = [.videoText, .audioText, .otherText]
    let frameRateArray = ["15", "20"]
    
    init() {
        createVideoItem()
        createAudioItem()
        createOtherItem()
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
        volumePromptItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.volumePromptAction(sender: view)
        }
        audioItems.append(volumePromptItem)
    }
    
    private func resolutionAction() {
        viewResponder?.showResolutionAlert()
    }
    
    private func createOtherItem() {
        let qualityItem = ListCellItemData()
        qualityItem.titleText = .qualityInspectionText
        qualityItem.hasOverAllAction = true
        qualityItem.hasRightButton = true
        let buttonData = ButtonItemData()
        buttonData.orientation = .right
        buttonData.normalIcon = "room_right_arrow1"
        buttonData.resourceBundle = tuiRoomKitBundle()
        buttonData.titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        buttonData.titleColor = UIColor(0xD1D9EC)
        buttonData.size = CGSize(width: 80, height: 30)
        buttonData.isEnabled = false
        qualityItem.buttonData = buttonData
        qualityItem.action = { [weak self] sender in
            guard let self = self else { return }
            self.showQualityAction()
        }
        otherItems.append(qualityItem)
        
        let floatChatItem = ListCellItemData()
        floatChatItem.titleText = .floatChatText
        floatChatItem.hasSwitch = true
        floatChatItem.isSwitchOn = store.shouldShowFloatChatView
        floatChatItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.floatChatShowAction(shouldShow: view.isOn)
        }
        otherItems.append(floatChatItem)
    }
    
    private func showQualityAction() {
        viewResponder?.showQualityView()
    }
    
    private func floatChatShowAction(shouldShow: Bool) {
        store.updateFloatChatShowState(shouldShow: shouldShow)
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
        videoItem.buttonData?.normalTitle = resolutionName
        viewResponder?.updateStackView(item: videoItem)
        engineManager.setVideoEncoder(videoQuality: quality, bitrate: getBitrate(videoQuality: quality))
    }
    
    func changeFrameRateAction(index: Int) {
        guard let videoItem = videoItems.first(where: { $0.type == .frameRateType }) else { return }
        guard let frameRate = frameRateArray[safe: index] else { return }
        videoItem.buttonData?.normalTitle = frameRate
        viewResponder?.updateStackView(item: videoItem)
        engineManager.setVideoEncoder(fps: Int(frameRate))
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
        localized("Video settings")
    }
    static var audioText: String {
        localized("Audio settings")
    }
    static var otherText: String {
        localized("Other settings")
    }
    static var versionLowToastText: String {
        localized("Your system version is below 12.0. Please update.")
    }
    static var resolutionText: String {
        localized("Resolution")
    }
    static var frameRateText: String {
        localized("Frame Rate")
    }
    static var bitrateText: String {
        localized("Bitrate")
    }
    static var localMirrorText: String {
        localized("Local Mirror")
    }
    static var captureVolumeText: String {
        localized("Capture Volume")
    }
    static var playVolumeText: String {
        localized("Playback Volume")
    }
    static var volumePromptText: String {
        localized("Volume Reminder")
    }
    static var audioRecordingText: String {
        localized("Audio Recording")
    }
    static var smoothResolutionText: String {
        localized("Smooth resolution")
    }
    static var standardResolutionText: String {
        localized("Standard resolution")
    }
    static var highResolutionText: String {
        localized("High resolution")
    }
    static var superResolutionText: String {
        localized("Super resolution")
    }
    static var qualityInspectionText: String {
        localized("Quality Inspection")
    }
    static var floatChatText: String {
        localized("Open Floating Chat")
    }
}
