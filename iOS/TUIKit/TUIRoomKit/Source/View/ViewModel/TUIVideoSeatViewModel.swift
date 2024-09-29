//
//  TUIVideoSeatPresenter.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/28.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine
#if canImport(TXLiteAVSDK_TRTC)
    import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
    import TXLiteAVSDK_Professional
#endif

protocol TUIVideoSeatViewModelResponder: AnyObject {
    func reloadData()
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    
    func getVideoVisibleCell(_ item: VideoSeatItem) -> VideoSeatCell?
    func getMoveMiniscreen() -> TUIVideoSeatDragCell
    
    func updateMiniscreen(_ item: VideoSeatItem?)
    func updateMiniscreenVolume(_ item: VideoSeatItem)
    
    func updateVideoSeatCellUI(_ item: VideoSeatItem)
    
    func updateSeatVolume(_ item: VideoSeatItem)
    
    func showScreenCaptureMaskView(isShow: Bool)
    
    func destroyVideoSeatResponder()
}

enum TUIVideoSeatViewType {
    case unknown
    case singleType
    case pureAudioType
    case largeSmallWindowType
    case speechType
    case equallyDividedType
}

class TUIVideoSeatViewModel: NSObject {
    private var videoSeatItems: [VideoSeatItem] = []
    private var shareItem: VideoSeatItem?
    private var speakerItem: VideoSeatItem?
    
    private var isSwitchPosition: Bool = false
    
    private var speakerUpdateTimer: Int = 0
    private let speakerUpdateTimeInterval = 5
    private var itemStreamType: TUIVideoStreamType {
        if listSeatItem.filter({ $0.hasVideoStream }).count > 5 {
            return .cameraStreamLow
        } else {
            return .cameraStream
        }
    }
    
    var listSeatItem: [VideoSeatItem] = []
    
    private var isHasVideoStream: Bool {
        return videoSeatItems.firstIndex(where: { $0.isHasVideoStream }) != nil
    }
    
    private var isHasScreenStream: Bool {
        return shareItem != nil
    }
    
    weak var viewResponder: TUIVideoSeatViewModelResponder?
    var videoSeatViewType: TUIVideoSeatViewType = .unknown
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var store: RoomStore {
        engineManager.store
    }
    var roomInfo: TUIRoomInfo {
        store.roomInfo
    }
    var currentUserId: String {
        store.currentUser.userId
    }
    
    override init() {
        super.init()
        initVideoSeatItems()
        subscribeUIEvent()
    }
    
    private func initVideoSeatItems() {
        videoSeatItems = []
        let videoItems = store.roomInfo.isSeatEnabled ? store.seatList : store.attendeeList
        guard videoItems.count > 0 else { return }
        videoItems.forEach { userInfo in
            let userItem = VideoSeatItem()
            userItem.update(userInfo: userInfo)
            videoSeatItems.append(userItem)
        }
        if let shareInfo = videoItems.first(where: { $0.hasScreenStream }) {
            updateShareItem(userInfo: shareInfo)
        }
        sortSeatItems()
        reloadSeatItems()
    }
    
    private func subscribeUIEvent() {
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewVideoSeatView, responder: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserVoiceVolumeChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserScreenCaptureStopped, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onRemoteUserEnterRoom, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onRemoteUserLeaveRoom, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onSeatListChanged, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, responder: self)
    }
    
    private func unsubscribeUIEvent() {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewVideoSeatView, responder: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVideoStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVoiceVolumeChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserScreenCaptureStopped, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onRemoteUserEnterRoom, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onRemoteUserLeaveRoom, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onSeatListChanged, observer: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, responder: self)
    }
    
    func updateShareItem(userInfo: UserEntity) {
        guard userInfo.hasScreenStream, shareItem == nil else { return }
        let item = VideoSeatItem()
        item.update(userInfo: userInfo)
        item.videoStreamType = .screenStream
        shareItem = item
    }
    
    deinit {
        unsubscribeUIEvent()
        debugPrint("deinit:\(self)")
    }
}

extension TUIVideoSeatViewModel {
    
    private func startPlayVideo(item: VideoSeatItem, renderView: UIView?) {
        guard let renderView = renderView else { return }
        if item.userId == currentUserId {
            engineManager.setLocalVideoView(streamType: item.videoStreamType, view: renderView)
        } else {
            item.videoStreamType = item.videoStreamType == .screenStream ? .screenStream : itemStreamType
            engineManager.setRemoteVideoView(userId: item.userId, streamType: item.videoStreamType, view: renderView)
            engineManager.startPlayRemoteVideo(userId: item.userId, streamType: item.videoStreamType)
        }
        guard let seatCell = viewResponder?.getVideoVisibleCell(item) else { return }
        seatCell.updateUI(item: item)
    }
    
    private func stopPlayVideo(item: VideoSeatItem) {
        if item.userId == currentUserId {
            engineManager.setLocalVideoView(streamType: item.videoStreamType, view: nil)
        } else {
            engineManager.setRemoteVideoView(userId: item.userId, streamType: item.videoStreamType, view: nil)
            engineManager.stopPlayRemoteVideo(userId: item.userId, streamType: item.videoStreamType)
        }
        guard let seatCell = viewResponder?.getVideoVisibleCell(item) else { return }
        seatCell.updateUI(item: item)
    }
    
    private func addUserInfo(_ userId: String) {
        guard !videoSeatItems.contains(where: { $0.userId == userId }) else { return }
        guard let userInfo = getUserInfo(userId: userId) else { return }
        let seatItem = VideoSeatItem()
        seatItem.update(userInfo: userInfo)
        videoSeatItems.append(seatItem)
        if checkNeededSort() {
            refreshListSeatItem()
            viewResponder?.reloadData()
            resetMiniscreen()
        } else {
            reloadSeatItems()
        }
    }
    
    private func getUserInfo(userId: String) -> UserEntity? {
        return store.attendeeList.first(where: { $0.userId == userId })
    }
    
    private func removeSeatItem(_ userId: String) {
        if shareItem?.userId == userId, let seatItem = shareItem {
            stopPlayVideo(item: seatItem)
        }
        if speakerItem?.userId == userId, let seatItem = speakerItem {
            stopPlayVideo(item: seatItem)
        }
        if let seatItem = videoSeatItems.first(where: { $0.userId == userId }) {
            stopPlayVideo(item: seatItem)
        }
        videoSeatItems.removeAll(where: { $0.userId == userId })
        var deleteIndex: [IndexPath] = []
        if let index = listSeatItem.firstIndex(where: { $0.userId == userId && $0.videoStreamType != .screenStream }) {
            deleteIndex.append(IndexPath(item: index, section: 0))
        }
        refreshListSeatItem()
        if videoSeatViewType == .largeSmallWindowType {
            viewResponder?.reloadData()
        } else {
            viewResponder?.deleteItems(at: deleteIndex)
        }
        resetMiniscreen()
    }
    
    private func changeUserRole(userId: String, userRole: TUIRole) {
        if let item = getSeatItem(userId) {
            item.userRole = userRole
            viewResponder?.updateVideoSeatCellUI(item)
        }
        if let shareItem = shareItem, shareItem.userId == userId {
            shareItem.userRole = userRole
            viewResponder?.updateVideoSeatCellUI(shareItem)
        }
        if let speakerItem = speakerItem, speakerItem.userId == userId {
            speakerItem.userRole = userRole
            viewResponder?.updateVideoSeatCellUI(speakerItem)
        }
        guard userRole == .roomOwner else { return }
        refreshListSeatItem()
        viewResponder?.reloadData()
        resetMiniscreen()
    }
    
    private func getSeatItem(_ userId: String) -> VideoSeatItem? {
        return videoSeatItems.first(where: { $0.userId == userId })
    }
    
    private func sortSeatItems() {
        guard checkNeededSort() else { return }
        //  I'm second
        if let currentItemIndex = videoSeatItems.firstIndex(where: { $0.userId == self.currentUserId }) {
            let currentItem = videoSeatItems.remove(at: currentItemIndex)
            videoSeatItems.insert(currentItem, at: 0)
        }
        // Homeowners always come first
        if let roomOwnerItemIndex = videoSeatItems.firstIndex(where: { $0.userId == roomInfo.ownerId }) {
            let roomOwnerItem = videoSeatItems.remove(at: roomOwnerItemIndex)
            videoSeatItems.insert(roomOwnerItem, at: 0)
        }
    }
    
    private func checkNeededSort() -> Bool {
        var isSort = false
        if let roomOwnerItemIndex = videoSeatItems.firstIndex(where: { $0.userId == roomInfo.ownerId }) {
            isSort = roomOwnerItemIndex != 0
        }
        if let currentItemIndex = videoSeatItems.firstIndex(where: { $0.userId == self.currentUserId }) {
            if currentUserId == roomInfo.ownerId {
                isSort = isSort || (currentItemIndex != 0)
            } else {
                isSort = isSort || (currentItemIndex != 1)
            }
        }
        return isSort
    }
    
    private func findCurrentSpeaker(list: [VideoSeatItem]) -> VideoSeatItem? {
        if let shareItem = shareItem {
            return list.first(where: { $0.hasAudioStream && $0.userVoiceVolume > 10 && $0.userId != shareItem.userId })
        } else if let speech = listSeatItem.first {
            return list.first(where:{  $0.hasAudioStream && $0.userVoiceVolume > 10 && $0.userId != speech.userId })
        }
        return nil
    }
    
    private func refreshListSeatItem() {
        sortSeatItems()
        listSeatItem = Array(videoSeatItems)
        if videoSeatItems.count == 1 {
            videoSeatViewType = .singleType
            if isHasScreenStream {
                refreshMultiVideo()
            }
        } else if videoSeatItems.count == 2, isHasVideoStream, !isHasScreenStream {
            videoSeatViewType = .largeSmallWindowType
            if isSwitchPosition {
                let first = listSeatItem[0]
                listSeatItem[0] = listSeatItem[1]
                listSeatItem[1] = first
            }
        } else if videoSeatItems.count >= 2, !isHasVideoStream, !isHasScreenStream {
            videoSeatViewType = .pureAudioType
        } else {
            refreshMultiVideo()
        }
    }
    
    private func refreshMultiVideo() {
        let videoResult = videoSeatItems.filter({ $0.hasVideoStream })
        var speechItem: VideoSeatItem?
        if let item = shareItem {
            speechItem = item
        } else if videoResult.count == 1, let item = videoResult.first {
            speechItem = item
        }
        if let item = speechItem, let seatItemIndex = videoSeatItems.firstIndex(where: { $0.userId == item.userId }) {
            videoSeatViewType = .speechType
            if item.videoStreamType == .screenStream, item.userId != currentUserId {
                listSeatItem.insert(item, at: 0)
            } else {
                listSeatItem.remove(at: seatItemIndex)
                listSeatItem.insert(item, at: 0)
                if item.userId == speakerItem?.userId {
                    speakerItem = nil
                }
            }
            if let currentSpeakerItem = findCurrentSpeaker(list: listSeatItem) {
                speakerItem = currentSpeakerItem
            } else {
                if let item = speakerItem, videoSeatItems.firstIndex(where: { $0.userId == item.userId }) == nil {
                    speakerItem = nil
                }
            }
        } else {
            videoSeatViewType = .equallyDividedType
        }
    }
    
    private func reloadSeatItems() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let type = self.videoSeatViewType
            let lastListSeatItem = Array(self.listSeatItem)
            self.refreshListSeatItem()
            self.updateCollectionView(type, lastListSeatItem)
            self.resetMiniscreen()
        }
    }
    
    private func resetMiniscreen() {
        if self.videoSeatViewType == .speechType {
            self.viewResponder?.updateMiniscreen(self.speakerItem)
        } else {
            self.speakerItem = nil
            self.viewResponder?.updateMiniscreen(nil)
        }
    }
    
    private func updateSeatVolume(item: VideoSeatItem) {
        viewResponder?.updateSeatVolume(item)
        if let shareItem = shareItem, shareItem.userId == item.userId {
            shareItem.hasAudioStream = item.hasAudioStream
            shareItem.userVoiceVolume = item.userVoiceVolume
            viewResponder?.updateSeatVolume(shareItem)
        }
        if let speakerItem = speakerItem, speakerItem.userId == item.userId {
            speakerItem.hasAudioStream = item.hasAudioStream
            speakerItem.userVoiceVolume = item.userVoiceVolume
            viewResponder?.updateMiniscreenVolume(speakerItem)
        }
    }
    
    private func updateCollectionView(_ type: TUIVideoSeatViewType, _ lastList: [VideoSeatItem]) {
        if type != videoSeatViewType {
            viewResponder?.reloadData()
        } else {
            let count = lastList.count
            let diffItem = listSeatItem.count - count
            var indexPaths: [IndexPath] = []
            if diffItem > 0 {
                for i in count ... (count + diffItem - 1) {
                    indexPaths.append(IndexPath(item: i, section: 0))
                }
                viewResponder?.insertItems(at: indexPaths)
            }
            for i in 0 ... min(max(count - 1, 0), max(listSeatItem.count - 1, 0)) {
                guard lastList.count > i && listSeatItem.count > i && lastList[i] != listSeatItem[i] else { continue }
                guard let item = listSeatItem[safe: i] else { continue }
                viewResponder?.updateVideoSeatCellUI(item)
                guard let cell = viewResponder?.getVideoVisibleCell(item) else { continue }
                if item.hasVideoStream {
                    startPlayVideo(item: item, renderView: cell.renderView)
                } else {
                    stopPlayVideo(item: item)
                }
            }
        }
    }
    
    private func isConformedSpeakerTimeInterval() -> Bool {
        let currentTime: TimeInterval = Date().timeIntervalSince1970
        let timeStamp = Int(currentTime)
        let totalTime: UInt = UInt(labs(timeStamp - speakerUpdateTimer))
        return totalTime > speakerUpdateTimeInterval
    }
}

extension TUIVideoSeatViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_RenewVideoSeatView:
            initVideoSeatItems()
        case .TUIRoomKitService_DismissConferenceViewController:
            viewResponder?.destroyVideoSeatResponder()
            viewResponder = nil
        default: break
        }
    }
}

extension TUIVideoSeatViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onUserAudioStateChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let hasAudio = param?["hasAudio"] as? Bool else { return }
            guard let seatItem = getSeatItem(userId) else { return }
            seatItem.hasAudioStream = hasAudio
            updateSeatVolume(item: seatItem)
        case .onUserVoiceVolumeChanged:
            guard let volumeMap = param as? [String: NSNumber] else { return }
            userVoiceVolumeChanged(volumeMap: volumeMap)
        case .onUserVideoStateChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let streamType = param?["streamType"] as? TUIVideoStreamType else { return }
            guard let hasVideo = param?["hasVideo"] as? Bool else { return }
            userVideoStateChanged(userId: userId, streamType: streamType, hasVideo: hasVideo)
        case .onUserScreenCaptureStopped:
            userScreenCaptureStopped()
        case .onRemoteUserEnterRoom:
            guard let userInfo = param?["userInfo"] as? TUIUserInfo else { return }
            guard !roomInfo.isSeatEnabled else { return }
            addUserInfo(userInfo.userId)
        case .onRemoteUserLeaveRoom:
            guard let userInfo = param?["userInfo"] as? TUIUserInfo else { return }
            removeSeatItem(userInfo.userId)
        case .onUserRoleChanged:
            guard let userId = param?["userId"] as? String else { return }
            guard let userRole = param?["userRole"] as? TUIRole else { return }
            engineManager.fetchRoomInfo(roomId: roomInfo.roomId) { [weak self] _ in
                guard let self = self else { return }
                self.changeUserRole(userId: userId, userRole: userRole)
            }
        case .onSeatListChanged:
            guard let left = param?["left"] as? [TUISeatInfo] else { return }
            guard let seated = param?["seated"] as? [TUISeatInfo] else { return }
            seatListChanged(seated: seated, left: left)
        default: break
        }
    }
}

extension TUIVideoSeatViewModel: TUIRoomObserver {
    private func userVoiceVolumeChanged(volumeMap: [String: NSNumber]) {
        if volumeMap.count <= 0 {
            return
        }
        for (userId, volume) in volumeMap {
            guard let seatItem = getSeatItem(userId) else { continue }
            seatItem.userVoiceVolume = volume.intValue
            updateSeatVolume(item: seatItem)
        }
        
        guard videoSeatViewType == .speechType else { return }
        guard let currentSpeakerItem = findCurrentSpeaker(list: listSeatItem) else { return }
        if viewResponder?.getMoveMiniscreen().seatItem != nil, speakerItem?.userId == currentSpeakerItem.userId {
            viewResponder?.updateMiniscreenVolume(currentSpeakerItem)
        } else {
            guard isConformedSpeakerTimeInterval() else { return }
            viewResponder?.updateMiniscreen(currentSpeakerItem)
            speakerUpdateTimer = Int(Date().timeIntervalSince1970)
        }
        speakerItem = currentSpeakerItem
    }
    
    private func userVideoStateChanged(userId: String, streamType: TUIVideoStreamType, hasVideo: Bool) {
        if streamType == .screenStream, userId == currentUserId {
            viewResponder?.showScreenCaptureMaskView(isShow: hasVideo)
            return
        }
        guard let seatItem = getSeatItem(userId) else { return }
        if streamType == .cameraStream || streamType == .cameraStreamLow {
            seatItem.hasVideoStream = hasVideo
            if hasVideo {
                setRemoteRenderParams(userId: userId, streamType: streamType)
                startPlayVideo(item: seatItem, renderView: viewResponder?.getVideoVisibleCell(seatItem)?.renderView)
            } else {
                stopPlayVideo(item: seatItem)
            }
            reloadSeatItems()
        } else {
            updateScreenStreamView(seatItem: seatItem, hasVideo: hasVideo)
        }
    }
    
    private func updateScreenStreamView(seatItem: VideoSeatItem, hasVideo: Bool) {
        let screenIndexPath = IndexPath(item: 0, section: 0)
        if hasVideo {
            guard let shareUserInfo = getUserInfo(userId: seatItem.userId) else { return }
            updateShareItem(userInfo: shareUserInfo)
            refreshListSeatItem()
            viewResponder?.insertItems(at: [screenIndexPath])
        } else {
            shareItem = nil
            refreshListSeatItem()
            if videoSeatViewType == .largeSmallWindowType {
                viewResponder?.reloadData()
            } else {
                viewResponder?.deleteItems(at: [screenIndexPath])
            }
        }
        speakerItem = nil
        viewResponder?.updateMiniscreen(nil)
    }
    
    private func setRemoteRenderParams(userId: String, streamType: TUIVideoStreamType) {
        let renderParams = TRTCRenderParams()
        renderParams.fillMode = (streamType == .screenStream) ? .fit : .fill
        let trtcStreamType: TRTCVideoStreamType = (streamType == .screenStream) ? .sub : .big
        engineManager.setRemoteRenderParams(userId: userId, streamType: trtcStreamType, params: renderParams)
    }
    
    private func seatListChanged(seated: [TUISeatInfo], left: [TUISeatInfo]) {
        for leftSeat in left {
            if let userId = leftSeat.userId {
                removeSeatItem(userId)
            }
        }
        for seatInfo in seated {
            if let userId = seatInfo.userId {
                addUserInfo(userId)
            }
        }
    }
    
    private func userScreenCaptureStopped() {
        viewResponder?.showScreenCaptureMaskView(isShow: false)
        if shareItem?.userId == currentUserId {
            shareItem = nil
        }
        reloadSeatItems()
    }
}

extension TUIVideoSeatViewModel: TUIVideoSeatViewResponder {
    func switchPosition() {
        guard videoSeatViewType == .largeSmallWindowType else { return }
        isSwitchPosition = !isSwitchPosition
        refreshListSeatItem()
        viewResponder?.reloadData()
        resetMiniscreen()
    }
    
    func clickVideoSeat() {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ChangeToolBarHiddenState, param: [:])
        guard RoomRouter.shared.hasChatWindow() else { return }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_HiddenChatWindow, param: [:])
    }
    
    func startPlayVideoStream(item: VideoSeatItem, renderView: UIView?) {
        startPlayVideo(item: item, renderView: renderView)
    }
    
    func stopPlayVideoStream(item: VideoSeatItem) {
        stopPlayVideo(item: item)
    }
    
    func updateSpeakerPlayVideoState(currentPageIndex: Int) {
        guard videoSeatViewType != .speechType else { return }
        if currentPageIndex == 0 {
            viewResponder?.updateMiniscreen(speakerItem)
        } else if let item = videoSeatItems.first(where: { $0.userId == speakerItem?.userId }),
                  let renderView = viewResponder?.getVideoVisibleCell(item)?.renderView {
            startPlayVideo(item: item, renderView: renderView)
        }
    }
    
    func stopScreenCapture() {
        EngineEventCenter.shared.notifyEngineEvent(event: .onUserScreenCaptureStopped, param: [:])
        engineManager.stopScreenCapture()
    }
}
