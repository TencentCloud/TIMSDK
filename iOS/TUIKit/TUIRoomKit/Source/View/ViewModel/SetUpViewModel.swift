//
//  SetUpViewModel.swift
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

protocol SetUpViewEventResponder: AnyObject {
    func showResolutionAlert()
    func showFrameRateAlert()
    func updateStackView(item: ListCellItemData, listIndex: Int, pageIndex: Int)
    func updateSegmentScrollView(selectedIndex: Int)
    func makeToast(text: String)
}

class SetUpViewModel {
    enum SetUpItemType: Int {
        case videoType
        case audioType
        case shareType
    }
    enum VideoItemType: Int {
        case resolutionItemType
        case frameRateItemType
        case bitrateItemType
    }
    private(set) var topItems: [ButtonItemData] = []
    private(set) var videoItems: [ListCellItemData] = []
    private(set) var audioItems: [ListCellItemData] = []
    weak var viewResponder: SetUpViewEventResponder? = nil
    let filePath: String
    let appGroupString: String
    var engineManager: EngineManager {
        EngineManager.shared
    }
    
    let bitrateTable = [BitrateTableData](
        arrayLiteral:
            BitrateTableData(resolutionName: "180 * 320",
                             resolution: TRTCVideoResolution._320_180,
                             defaultBitrate: 350,
                             minBitrate: 80,
                             maxBitrate: 350,
                             stepBitrate: 10),
        BitrateTableData(resolutionName: "270 * 480",
                         resolution: TRTCVideoResolution._480_270,
                         defaultBitrate: 500,
                         minBitrate: 200,
                         maxBitrate: 1_000,
                         stepBitrate: 10),
        BitrateTableData(resolutionName: "360 * 640",
                         resolution: TRTCVideoResolution._640_360,
                         defaultBitrate: 600,
                         minBitrate: 200,
                         maxBitrate: 1_000,
                         stepBitrate: 10),
        BitrateTableData(resolutionName: "540 * 960",
                         resolution: TRTCVideoResolution._960_540,
                         defaultBitrate: 900,
                         minBitrate: 400,
                         maxBitrate: 1_600,
                         stepBitrate: 50),
        BitrateTableData(resolutionName: "720 * 1280",
                         resolution: TRTCVideoResolution._1280_720,
                         defaultBitrate: 1_250,
                         minBitrate: 500,
                         maxBitrate: 2_000,
                         stepBitrate: 50)
    )
    
    let frameRateTable = [BitrateTableData](
        arrayLiteral:
            BitrateTableData(resolutionName: "15",
                             resolution: TRTCVideoResolution._320_180,
                             defaultBitrate: 350,
                             minBitrate: 80,
                             maxBitrate: 350,
                             stepBitrate: 10),
        BitrateTableData(resolutionName: "20",
                         resolution: TRTCVideoResolution._480_270,
                         defaultBitrate: 500,
                         minBitrate: 200,
                         maxBitrate: 1_000,
                         stepBitrate: 10)
    )
    let frameRateArray = [15, 20]
    
    init() {
        filePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                        FileManager.SearchPathDomainMask.userDomainMask,
                                                        true).last?.appending("/test-record.aac") ?? ""
        appGroupString = "com.tencent.TUIRoomTXReplayKit-Screen"
        createTopItem()
        createVideoItem()
        createAudioItem()
    }
    
    func createTopItem() {
        let videoSetItem = ButtonItemData()
        videoSetItem.normalTitle = .videoText
        videoSetItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.videoSetAction(sender: button)
        }
        topItems.append(videoSetItem)
        
        let audioSetItem = ButtonItemData()
        audioSetItem.normalTitle = .audioText
        audioSetItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.audioSetAction(sender: button)
        }
        topItems.append(audioSetItem)
        
        let shareItem = ButtonItemData()
        shareItem.normalTitle = .shareText
        shareItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.shareAction(sender: button)
        }
        topItems.append(shareItem)
    }
    
    func updateSetUpItemView(item: ListCellItemData, listIndex: Int, pageIndex: Int) {
        viewResponder?.updateStackView(item: item, listIndex: listIndex, pageIndex: pageIndex)
    }
    
    func videoSetAction(sender: UIButton) {
        viewResponder?.updateSegmentScrollView(selectedIndex: SetUpItemType.videoType.rawValue)
    }
    
    func audioSetAction(sender: UIButton) {
        viewResponder?.updateSegmentScrollView(selectedIndex: SetUpItemType.audioType.rawValue)
    }
    
    func shareAction(sender: UIButton) {
        viewResponder?.updateSegmentScrollView(selectedIndex: SetUpItemType.shareType.rawValue)
    }
    
    func createVideoItem() {
        let resolutionItem = ListCellItemData()
        resolutionItem.titleText = .resolutionText
        resolutionItem.messageText = engineManager.store.videoSetting.bitrate.resolutionName
        resolutionItem.hasOverAllAction = true
        resolutionItem.action = { [weak self] sender in
            guard let self = self else { return }
            self.resolutionAction()
        }
        videoItems.append(resolutionItem)
        
        let frameRateItem = ListCellItemData()
        frameRateItem.titleText = .frameRateText
        frameRateItem.messageText = String(engineManager.store.videoSetting.videoFps)
        frameRateItem.hasOverAllAction = true
        frameRateItem.action = { [weak self] sender in
            guard let self = self else { return }
            self.frameRateAction()
        }
        videoItems.append(frameRateItem)
        
        let bitrateItem = ListCellItemData()
        bitrateItem.titleText = .bitrateText
        bitrateItem.hasSlider = true
        bitrateItem.hasSliderLabel = true
        bitrateItem.minimumValue = engineManager.store.videoSetting.bitrate.minBitrate
        bitrateItem.maximumValue = engineManager.store.videoSetting.bitrate.maxBitrate
        bitrateItem.sliderUnit = "kbps"
        bitrateItem.sliderStep = engineManager.store.videoSetting.bitrate.stepBitrate
        bitrateItem.sliderDefault = Float(engineManager.store.videoSetting.videoBitrate)
        bitrateItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISlider else { return }
            self.bitrateAction(sender: view)
        }
        videoItems.append(bitrateItem)
        
        let localMirrorItem = ListCellItemData()
        localMirrorItem.titleText = .localMirrorText
        localMirrorItem.hasSwitch = true
        localMirrorItem.isSwitchOn = engineManager.store.videoSetting.isMirror
        localMirrorItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.localMirrorAction(sender: view)
        }
        videoItems.append(localMirrorItem)
    }
    
    func resolutionAction() {
        viewResponder?.showResolutionAlert()
    }
    
    func changeResolutionAction(index: Int) {
        engineManager.store.videoSetting.bitrate = bitrateTable[index]
        engineManager.store.videoSetting.videoBitrate = Int(engineManager.store.videoSetting.bitrate.defaultBitrate)
        engineManager.store.videoSetting.videoResolution = bitrateTable[index].resolution
        guard let videoItem = videoItems[safe: VideoItemType.resolutionItemType.rawValue] else { return }
        videoItem.messageText = engineManager.store.videoSetting.bitrate.resolutionName
        updateSetUpItemView(item: videoItem, listIndex: VideoItemType.resolutionItemType.rawValue, pageIndex: SetUpItemType.videoType.rawValue)
        updateBitrateItemView(index: index)
    }
    
    func changeFrameRateAction(index: Int) {
        guard let videoItem = videoItems[safe: VideoItemType.frameRateItemType.rawValue] else { return }
        videoItem.messageText = String(frameRateArray[index])
        updateSetUpItemView(item: videoItem, listIndex: VideoItemType.frameRateItemType.rawValue, pageIndex: SetUpItemType.videoType.rawValue)
        engineManager.store.videoSetting.videoFps = frameRateArray[index]
        updateVideoEncoderParam()
    }
    
    func updateBitrateItemView(index: Int) {
        engineManager.store.videoSetting.bitrate = bitrateTable[index]
        engineManager.store.videoSetting.videoBitrate = Int(engineManager.store.videoSetting.bitrate.defaultBitrate)
        updateVideoEncoderParam()
        guard let bitrateItem = videoItems[safe: VideoItemType.bitrateItemType.rawValue] else { return }
        bitrateItem.minimumValue = engineManager.store.videoSetting.bitrate.minBitrate
        bitrateItem.maximumValue = engineManager.store.videoSetting.bitrate.maxBitrate
        bitrateItem.sliderDefault = engineManager.store.videoSetting.bitrate.defaultBitrate
        bitrateItem.sliderStep = engineManager.store.videoSetting.bitrate.stepBitrate
        updateSetUpItemView(item: bitrateItem, listIndex: VideoItemType.bitrateItemType.rawValue, pageIndex: SetUpItemType.videoType.rawValue)
    }
    
    func updateVideoEncoderParam() {
        let param = TRTCVideoEncParam()
        param.videoResolution = engineManager.store.videoSetting.videoResolution
        param.videoBitrate = Int32(engineManager.store.videoSetting.videoBitrate)
        param.videoFps = Int32(engineManager.store.videoSetting.videoFps)
        param.enableAdjustRes = true
        engineManager.roomEngine.getTRTCCloud().setVideoEncoderParam(param)
    }
    
    func frameRateAction() {
        viewResponder?.showFrameRateAlert()
    }
    
    func bitrateAction(sender: UISlider) {
        let bitrate = Int(sender.value) * Int(engineManager.store.videoSetting.bitrate.stepBitrate)
        engineManager.store.videoSetting.videoBitrate = bitrate
        updateVideoEncoderParam()
    }
    
    func localMirrorAction(sender: UISwitch) {
        engineManager.store.videoSetting.isMirror = sender.isOn
        let params = TRTCRenderParams()
        params.fillMode = .fill
        params.rotation = ._0
        if engineManager.store.videoSetting.isMirror {
            params.mirrorType = .enable
        } else {
            params.mirrorType = .disable
        }
        engineManager.roomEngine.getTRTCCloud().setLocalRenderParams(params)
    }
    
    func createAudioItem() {
        let captureVolumeItem = ListCellItemData()
        captureVolumeItem.titleText = .captureVolumeText
        captureVolumeItem.hasSlider = true
        captureVolumeItem.hasSliderLabel = true
        captureVolumeItem.minimumValue = 0
        captureVolumeItem.maximumValue = 100
        captureVolumeItem.sliderStep = 1
        captureVolumeItem.sliderDefault = Float(engineManager.store.audioSetting.captureVolume)
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
        playingVolumeItem.sliderDefault = Float(engineManager.store.audioSetting.playVolume)
        playingVolumeItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISlider else { return }
            self.playingVolumeAction(sender: view)
        }
        audioItems.append(playingVolumeItem)
        
        let volumePromptItem = ListCellItemData()
        volumePromptItem.titleText = .volumePromptText
        volumePromptItem.hasSwitch = true
        volumePromptItem.isSwitchOn = engineManager.store.audioSetting.volumePrompt
        volumePromptItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.volumePromptAction(sender: view)
        }
        audioItems.append(volumePromptItem)
    }
    
    func captureVolumeAction(sender: UISlider) {
        engineManager.store.audioSetting.captureVolume = Int(sender.value)
        engineManager.roomEngine.getTRTCCloud().setAudioCaptureVolume(engineManager.store.audioSetting.captureVolume)
    }
    
    func playingVolumeAction(sender: UISlider) {
        engineManager.store.audioSetting.playVolume = Int(sender.value)
        engineManager.roomEngine.getTRTCCloud().setAudioPlayoutVolume(engineManager.store.audioSetting.playVolume)
    }
    
    func volumePromptAction(sender: UISwitch) {
        engineManager.store.audioSetting.volumePrompt = sender.isOn
        if engineManager.store.audioSetting.volumePrompt {
            engineManager.roomEngine.getTRTCCloud().enableAudioVolumeEvaluation(300, enable_vad: true)
        } else {
            engineManager.roomEngine.getTRTCCloud().enableAudioVolumeEvaluation(0, enable_vad: false)
        }
    }
    
    func shareStartAction(sender: UIButton) {
        if #available(iOS 12.0, *) {
            engineManager.roomEngine.startScreenCapture(appGroup: appGroupString)
            BroadcastLauncher.launch()
        } else {
            viewResponder?.makeToast(text: .versionLowToastText)
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var videoText: String {
        localized("TUIRoom.video")
    }
    static var audioText: String {
        localized("TUIRoom.audio")
    }
    static var shareText: String {
        localized("TUIRoom.share")
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
}
