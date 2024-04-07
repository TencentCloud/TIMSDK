//
//  TUIVideoSeatPresenter.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/28.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif

protocol TUIVideoSeatViewResponder: AnyObject {
    func reloadData()
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    
    func getVideoVisibleCell(_ item: VideoSeatItem) -> VideoSeatCell?
    func getMoveMiniscreen() -> TUIVideoSeatDragCell
    
    func updateMiniscreen(_ item: VideoSeatItem?)
    func updateMiniscreenVolume(_ item: VideoSeatItem)
    
    func updateSeatItem(_ item: VideoSeatItem)
    func updateSeatVolume(_ item: VideoSeatItem)
    
    func showScreenCaptureMaskView(isShow: Bool)
}

// 视图类型
enum TUIVideoSeatViewType {
    case unknown
    case singleType // 单人模式
    case pureAudioType // 纯音频
    case largeSmallWindowType // 大小窗
    case speechType // 演讲者模式
    case equallyDividedType // 等分模式
}

class TUIVideoSeatViewModel: NSObject {
    private var videoSeatItems: [VideoSeatItem] = []
    // 当前分享者
    private var shareItem: VideoSeatItem?
    // 当前说话者
    private var speakerItem: VideoSeatItem?
    // 小画面item
    private var smallItem: VideoSeatItem?
    
    private var isSwitchPosition: Bool = false
    
    private var speakerUpdateTimer: Int = 0 //演讲者更新的时间戳
    private let speakerUpdateTimeInterval = 5 //演讲者更新的时间间隔
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
        return videoSeatItems.firstIndex(where: { $0.hasScreenStream }) != nil
    }
    
    weak var viewResponder: TUIVideoSeatViewResponder?
    var videoSeatViewType: TUIVideoSeatViewType = .unknown
    var engineManager: EngineManager {
        EngineManager.createInstance()
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
            let userItem = VideoSeatItem(userInfo: userInfo)
            videoSeatItems.append(userItem)
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
    }
    
    deinit {
        unsubscribeUIEvent()
        debugPrint("deinit:\(self)")
    }
}

// MARK: - Public

extension TUIVideoSeatViewModel {
    func isHomeOwner(_ userId: String) -> Bool {
        return roomInfo.ownerId == userId
    }
    
    func switchPosition() {
        if videoSeatViewType == .largeSmallWindowType {
            isSwitchPosition = !isSwitchPosition
            refreshListSeatItem()
            resetMiniscreen()
            viewResponder?.reloadData()
        }
    }
    
    func updateSpeakerPlayVideoState(currentPageIndex: Int) {
        // currentPageIndex : 0,1,2,3
        if videoSeatViewType != .speechType {
            return
        }
        if currentPageIndex == 0 {
            viewResponder?.updateMiniscreen(speakerItem)
        } else if let item = videoSeatItems.first(where: { $0.userId == speakerItem?.userId }),
                  let renderView = viewResponder?.getVideoVisibleCell(item)?.renderView {
            startPlayVideo(item: item, renderView: renderView)
        }
    }
    
    func startPlayVideo(item: VideoSeatItem, renderView: UIView?) {
        guard let renderView = renderView else { return }
        if item.userId == currentUserId {
            engineManager.setLocalVideoView(streamType: item.streamType, view: renderView)
        } else {
            item.updateStreamType(streamType: itemStreamType)
            engineManager.setRemoteVideoView(userId: item.userId, streamType: item.streamType, view: renderView)
            engineManager.startPlayRemoteVideo(userId: item.userId, streamType: item.streamType, onSuccess: { [weak self] in
                guard let self = self else { return }
                if item == self.viewResponder?.getMoveMiniscreen().seatItem {
                    self.viewResponder?.getMoveMiniscreen().updateUI(item: item)
                }
            })
        }
        guard let seatCell = viewResponder?.getVideoVisibleCell(item) else { return }
        seatCell.updateUI(item: item)
    }
    
    func stopPlayVideo(item: VideoSeatItem) {
        unboundCell(item: item)
        if item.userId != currentUserId {
            engineManager.stopPlayRemoteVideo(userId: item.userId, streamType: item.streamType)
        }
        guard let seatCell = viewResponder?.getVideoVisibleCell(item) else { return }
        seatCell.updateUI(item: item)
    }
    
    private func unboundCell(item: VideoSeatItem) {
        if item.userId == currentUserId {
            engineManager.setLocalVideoView(streamType: item.streamType, view: nil)
        } else {
            if item.streamType != .screenStream {
                engineManager.setRemoteVideoView(userId: item.userId, streamType: .cameraStreamLow, view: nil)
            }
            engineManager.setRemoteVideoView(userId: item.userId, streamType: item.streamType, view: nil)
        }
    }
    
    func clickVideoSeat() {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ChangeToolBarHiddenState, param: [:])
        guard RoomRouter.shared.hasChatWindow() else { return }
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_HiddenChatWindow, param: [:])
    }
    
    func stopScreenCapture() {
        EngineEventCenter.shared.notifyEngineEvent(event: .onUserScreenCaptureStopped, param: [:])
        engineManager.stopScreenCapture()
    }
}

// MARK: - Private

extension TUIVideoSeatViewModel {
    private func addUserInfo(_ userId: String) {
        guard !videoSeatItems.contains(where: { $0.userId == userId }) else { return }
        guard let userInfo = store.attendeeList.first(where: { $0.userId == userId }) else { return }
        let seatItem = VideoSeatItem(userInfo: userInfo)
        videoSeatItems.append(seatItem)
        reloadSeatItems()
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
        let index = listSeatItem.firstIndex(where: { $0.userId == userId && $0.type != .share })
        let item = listSeatItem.first(where: { $0.userId == userId && $0.type != .share })
        let type = videoSeatViewType
        refreshListSeatItem()
        resetMiniscreen()
        if type == videoSeatViewType, let index = index, let item = item, viewResponder?.getVideoVisibleCell(item) == nil {
            viewResponder?.deleteItems(at: [IndexPath(item: index, section: 0)])
        } else {
            viewResponder?.reloadData()
        }
    }
    
    private func changeUserRole(userId: String, userRole: TUIRole) {
        if let item = getSeatItem(userId) {
            item.userInfo.userRole = userRole
            viewResponder?.updateSeatItem(item)
        }
        if let shareItem = shareItem, shareItem.userId == userId {
            shareItem.userInfo.userRole = userRole
            viewResponder?.updateSeatItem(shareItem)
        }
        if let speakerItem = speakerItem, speakerItem.userId == userId {
            speakerItem.userInfo.userRole = userRole
            viewResponder?.updateSeatItem(speakerItem)
        }
        if let smallItem = smallItem, smallItem.userId == userId {
            smallItem.userInfo.userRole = userRole
            viewResponder?.updateSeatItem(smallItem)
        }
        if userRole == .roomOwner {
            reloadSeatItems()
        }
    }
    
    private func getSeatItem(_ userId: String) -> VideoSeatItem? {
        return videoSeatItems.first(where: { $0.userId == userId })
    }
    
    private func sortSeatItems() {
        guard checkNeededSort() else { return }
        //  自己在第二位
        if let currentItemIndex = videoSeatItems.firstIndex(where: { $0.userId == self.currentUserId }) {
            let currentItem = videoSeatItems.remove(at: currentItemIndex)
            videoSeatItems.insert(currentItem, at: 0)
        }
        // 房主永远在第一位
        if let roomOwnerItemIndex = videoSeatItems.firstIndex(where: { $0.userId == roomInfo.ownerId }) {
            let roomOwnerItem = videoSeatItems.remove(at: roomOwnerItemIndex)
            videoSeatItems.insert(roomOwnerItem, at: 0)
        }
        
        viewResponder?.reloadData()
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
        let array = list.filter({ $0.type == .original })
        var currentSpeakerItem: VideoSeatItem?
        if shareItem == nil, let speech = listSeatItem.first {
            currentSpeakerItem = array.first(where: { $0.userId != speech.userId && $0.audioVolume > 10 })
        } else {
            currentSpeakerItem = array.first(where: { $0.audioVolume > 10 })
        }
        return currentSpeakerItem
    }
    
    //判断type状态
    private func refreshListSeatItem() {
        sortSeatItems()
        listSeatItem = Array(videoSeatItems)
        if videoSeatItems.count == 1 {
            // 单人
            videoSeatViewType = .singleType
            if isHasScreenStream {
                refreshMultiVideo()
            }
        } else if videoSeatItems.count == 2, isHasVideoStream,!isHasScreenStream {
            // 双人 大小窗切换
            videoSeatViewType = .largeSmallWindowType
            if isSwitchPosition {
                let first = listSeatItem[0]
                listSeatItem[0] = listSeatItem[1]
                listSeatItem[1] = first
            }
            smallItem = listSeatItem[1]
            listSeatItem = [listSeatItem[0]]
        } else if videoSeatItems.count >= 2, !isHasVideoStream {
            // 多人 纯音频模式
            videoSeatViewType = .pureAudioType
        } else {
            refreshMultiVideo()
        }
    }
    
    private func refreshMultiVideo() {
        let screenResult = videoSeatItems.filter({ $0.hasScreenStream })
        let videoResult = videoSeatItems.filter({ $0.hasVideoStream })
        var speechItem: VideoSeatItem?
        if screenResult.count == 1, let item = screenResult.first {
            // 有分享
            speechItem = item
        } else if videoResult.count == 1, let item = videoResult.first {
            // 只有一路视频
            speechItem = item
        }
        
        if let item = speechItem, let seatItemIndex = videoSeatItems.firstIndex(where: { $0.userId == item.userId }) {
            // 演讲者
            videoSeatViewType = .speechType
            if item.hasScreenStream, item.userId != currentUserId {
                // 屏幕分享 克隆，放到第一个位置
                videoSeatViewType = .speechType
                let shareItem = item.cloneShare()
                listSeatItem.insert(shareItem, at: 0)
                self.shareItem = shareItem
            } else {
                shareItem = nil
                // 唯一视频流 前置第一个位置
                listSeatItem.remove(at: seatItemIndex)
                listSeatItem.insert(item, at: 0)
                if item.userId == speakerItem?.userId {
                    speakerItem = nil
                }
            }
            if let currentSpeakerItem = findCurrentSpeaker(list: listSeatItem), currentSpeakerItem.hasAudioStream {
                speakerItem = currentSpeakerItem
            } else {
                // 全部静音，且speakerItem已经离开了
                if let item = speakerItem, videoSeatItems.firstIndex(where: { $0.userId == item.userId }) == nil {
                    speakerItem = nil
                }
            }
        } else {
            // 多人 多视频
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
        if self.videoSeatViewType == .largeSmallWindowType {
            self.speakerItem = nil
            self.shareItem = nil
            self.viewResponder?.updateMiniscreen(self.smallItem)
        } else if self.videoSeatViewType == .speechType {
            self.smallItem = nil
            self.viewResponder?.updateMiniscreen(self.speakerItem)
        } else {
            self.smallItem = nil
            self.speakerItem = nil
            self.shareItem = nil
            self.viewResponder?.updateMiniscreen(nil)
        }
    }
    
    private func updateSeatVolume(item: VideoSeatItem) {
        viewResponder?.updateSeatVolume(item)
        if let shareItem = shareItem, shareItem.userId == item.userId {
            shareItem.hasAudioStream = item.hasAudioStream
            shareItem.audioVolume = item.audioVolume
            viewResponder?.updateSeatVolume(shareItem)
        }
        
        if let speakerItem = speakerItem, speakerItem.userId == item.userId {
            speakerItem.hasAudioStream = item.hasAudioStream
            speakerItem.audioVolume = item.audioVolume
            viewResponder?.updateMiniscreenVolume(speakerItem)
        }
        
        if let smallItem = smallItem, smallItem.userId == item.userId {
            smallItem.hasAudioStream = item.hasAudioStream
            smallItem.audioVolume = item.audioVolume
            viewResponder?.updateMiniscreenVolume(smallItem)
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
                if lastList.count > i && listSeatItem.count > i && lastList[i] != listSeatItem[i] {
                    if let item = listSeatItem[safe: i] {
                        viewResponder?.updateSeatItem(item)
                    }
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
            engineManager.fetchRoomInfo() { [weak self] in
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
            seatItem.audioVolume = volume.intValue
            updateSeatVolume(item: seatItem)
        }
        
        if videoSeatViewType == .speechType {
            guard let currentSpeakerItem = findCurrentSpeaker(list: listSeatItem), currentSpeakerItem.hasAudioStream else { return }
            if speakerItem?.userId == currentSpeakerItem.userId {
                viewResponder?.updateMiniscreenVolume(currentSpeakerItem)
            } else {
                guard isConformedSpeakerTimeInterval() else { return }
                viewResponder?.updateMiniscreen(currentSpeakerItem)
                speakerUpdateTimer = Int(Date().timeIntervalSince1970)
            }
            speakerItem = currentSpeakerItem
        }
    }
    
    private func userVideoStateChanged(userId: String, streamType: TUIVideoStreamType, hasVideo: Bool) {
        if streamType == .screenStream, userId == currentUserId {
            viewResponder?.showScreenCaptureMaskView(isShow: hasVideo)
            return
        }
        guard var seatItem = getSeatItem(userId) else { return }
        if streamType == .cameraStream {
            seatItem.hasVideoStream = hasVideo
        } else if streamType == .screenStream {
            seatItem.hasScreenStream = hasVideo
        }
        if hasVideo {
            setRemoteRenderParams(userId: userId, streamType: streamType)
            startPlayVideo(item: seatItem, renderView: viewResponder?.getVideoVisibleCell(seatItem)?.renderView)
        } else {
            stopPlayVideo(item: seatItem)
        }
        if streamType == .cameraStream {
            reloadSeatItems()
        } else if streamType == .screenStream {
            updateScreenStreamView(hasVideo: hasVideo)
        }
    }
    
    private func updateScreenStreamView(hasVideo: Bool) {
        if !hasVideo {
            reloadSeatItems()
        } else {
            guard videoSeatItems.filter({ $0.hasScreenStream }).count == 1 else { return }
            if videoSeatViewType == .largeSmallWindowType {
                reloadSeatItems()
            } else {
                refreshListSeatItem()
                viewResponder?.insertItems(at: [IndexPath(item: 0, section: 0)])
                resetMiniscreen()
            }
        }
    }
    
    private func setRemoteRenderParams(userId: String, streamType: TUIVideoStreamType) {
        let renderParams = TRTCRenderParams()
        renderParams.fillMode = (streamType == .screenStream) ? .fit : .fill
        let trtcStreamType: TRTCVideoStreamType = (streamType == .screenStream) ? .sub : .big
        engineManager.setRemoteRenderParams(userId: userId, streamType: trtcStreamType, params: renderParams)
    }
    
    // seatList: 当前麦位列表  seated: 新增上麦的用户列表 left: 下麦的用户列表
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
        guard let seatItem = getSeatItem(currentUserId) else { return }
        seatItem.hasScreenStream = false
        reloadSeatItems()
    }
}
