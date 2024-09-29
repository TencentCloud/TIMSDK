//
//  QualityInfoViewModel.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/4/19.
//  Copyright © 2024 Tencent. All rights reserved.
//

import Foundation
#if canImport(TXLiteAVSDK_TRTC)
    import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
    import TXLiteAVSDK_Professional
#endif

protocol QualityViewResponder: AnyObject {
    func reloadData()
}

class QualityCellModel: NSObject {
    enum CellType {
        case upDown
        case normal
    }
    var titleText: String = ""
    var type: CellType = .upDown
    var uplinkString: String = ""
    var downlinkString: String = ""
    var normalString: String = ""
}

class QualitySectionModel: NSObject {
    var titleText: String = ""
    var items: [QualityCellModel] = []
}

class QualityInfoViewModel: NSObject {
    static let timeSuffix = "ms"
    static let lossSuffix = "%"
    static let bitrateSuffix = "kbps"
    static let framerateSuffix = "FPS"
    
    var sections: [QualitySectionModel] = []
    weak var viewResponder: QualityViewResponder? = nil
    
    private var rttCellModel: QualityCellModel = {
        var rttCellModel = QualityCellModel()
        rttCellModel.titleText = .rttString
        rttCellModel.normalString = "0" + timeSuffix
        rttCellModel.type = .normal
        return rttCellModel
    }()
    
    private var lossCellModel: QualityCellModel = {
        var lossCellModel = QualityCellModel()
        lossCellModel.titleText = .lossString
        lossCellModel.uplinkString = "0" + lossSuffix
        lossCellModel.downlinkString = "0" + lossSuffix
        return lossCellModel
    }()
    
    private var audioBitrateCellModel: QualityCellModel = {
        var bitrateCellModel = QualityCellModel()
        bitrateCellModel.titleText = .bitrateString
        bitrateCellModel.uplinkString = "0" + bitrateSuffix
        bitrateCellModel.downlinkString = "0" + bitrateSuffix
        return bitrateCellModel
    }()
    
    private var videoResCellModel: QualityCellModel = {
        var resCellModel = QualityCellModel()
        resCellModel.titleText = .resolutionString
        resCellModel.uplinkString = "0x0"
        resCellModel.downlinkString = "0x0"
        return resCellModel
    }()
    
    private var videoFrameRateCellModel: QualityCellModel = {
        var frameCellModel = QualityCellModel()
        frameCellModel.titleText = .frameRateString
        frameCellModel.uplinkString = "0" + framerateSuffix
        frameCellModel.downlinkString = "0" + framerateSuffix
        return frameCellModel
    }()
    
    private var videoBitrateCellModel: QualityCellModel = {
        var bitrateCellModel = QualityCellModel()
        bitrateCellModel.titleText = .bitrateString
        bitrateCellModel.uplinkString = "0" + bitrateSuffix
        bitrateCellModel.downlinkString = "0" + bitrateSuffix
        return bitrateCellModel
    }()
    
    override init() {
        super.init()
        self.addSection(with: [self.rttCellModel, self.lossCellModel], title: .networkString)
        self.addSection(with: [self.audioBitrateCellModel], title: .audioString)
        self.addSection(with:  [self.videoResCellModel, self.videoFrameRateCellModel, self.videoBitrateCellModel], title: .videoString)
        subscribeEngine()
    }
    
    private func addSection(with items: [QualityCellModel], title: String) {
        let section = QualitySectionModel()
        section.titleText = title
        section.items = items
        self.sections.append(section)
    }
    
    private func subscribeEngine() {
        EngineEventCenter.shared.subscribeEngine(event: .onStatistics, observer: self)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onStatistics, observer: self)
    }
    
    deinit {
        unsubscribeEngine()
    }
}

extension QualityInfoViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onStatistics:
            guard let data = param?["statistics"] as? TRTCStatistics else { return }
            handleStatistics(data: data)
        default:
            break
        }
    }
    
    private func handleStatistics(data: TRTCStatistics) {
        let localStatistics = data.localStatistics.first(where: { $0.streamType == .big })
        let remoteStatistics = data.remoteStatistics ?? []
        
        self.rttCellModel.normalString = String(data.rtt) + QualityInfoViewModel.timeSuffix
        // assemble uplink data
        self.lossCellModel.uplinkString = String(data.upLoss) + QualityInfoViewModel.lossSuffix
        self.audioBitrateCellModel.uplinkString = String(localStatistics?.audioBitrate ?? 0) + QualityInfoViewModel.bitrateSuffix
        self.videoResCellModel.uplinkString = String(localStatistics?.width ?? 0) + "x" + String(localStatistics?.height ?? 0)
        self.videoFrameRateCellModel.uplinkString = String(localStatistics?.frameRate ?? 0) + QualityInfoViewModel.framerateSuffix
        self.videoBitrateCellModel.uplinkString = String(localStatistics?.videoBitrate ?? 0) + QualityInfoViewModel.bitrateSuffix
        
        // assemble downlink data
        let remoteSumAudioBitrate = remoteStatistics.reduce(0) { sum, stream in
            return sum + stream.audioBitrate
        }
        let remoteMaxFramerate = remoteStatistics.max(by: {$0.frameRate < $1.frameRate})
        let remoteMaxVideoRes = remoteStatistics.max(by: { $0.width * $0.height < $1.width * $1.height })
        let remoteSumVideoBitrate = remoteStatistics.reduce(0) { sum, stream in
            return sum + stream.videoBitrate
        }
        self.lossCellModel.downlinkString = String(data.downLoss) + QualityInfoViewModel.lossSuffix
        self.audioBitrateCellModel.downlinkString = String(remoteSumAudioBitrate) + QualityInfoViewModel.bitrateSuffix
        self.videoResCellModel.downlinkString = String(remoteMaxVideoRes?.width ?? 0) + "x" + String(remoteMaxVideoRes?.height ?? 0)
        self.videoFrameRateCellModel.downlinkString = String(remoteMaxFramerate?.frameRate ?? 0) + QualityInfoViewModel.framerateSuffix
        self.videoBitrateCellModel.downlinkString = String(remoteSumVideoBitrate) + QualityInfoViewModel.bitrateSuffix
        
        self.viewResponder?.reloadData()
    }
}

private extension String {
    static var networkString: String {
        localized("Network")
    }
    static var audioString: String {
        localized("Audio")
    }
    static var videoString: String {
        localized("Video")
    }
    static var rttString: String {
        localized("Latency")
    }
    static var lossString: String {
        localized("Packet Loss Rate")
    }
    static var bitrateString: String {
        localized("Bitrate")
    }
    static var resolutionString: String {
        localized("Resolution")
    }
    static var frameRateString: String {
        localized("Frame Rate")
    }
}

