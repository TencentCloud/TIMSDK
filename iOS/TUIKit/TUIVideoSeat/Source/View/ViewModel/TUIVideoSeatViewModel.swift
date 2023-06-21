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

    func getSeatVideoRenderView(_ item: VideoSeatItem) -> UIView?

    func updateMiniscreen(_ item: VideoSeatItem?)
    func updateMiniscreenVolume(_ item: VideoSeatItem)

    func updateSeatItem(_ item: VideoSeatItem)
    func updateSeatVolume(_ item: VideoSeatItem)
}

// 视图类型
enum TUIVideoSeatViewType {
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

    var listSeatItem: [VideoSeatItem] = []

    private var isHasVideoStream: Bool {
        guard videoSeatItems.firstIndex(where: { $0.isHasVideoStream }) != nil else { return false }
        return true
    }

    private var isHasScreenStream: Bool {
        guard videoSeatItems.firstIndex(where: { $0.hasScreenStream }) != nil else { return false }
        return true
    }

    weak var viewResponder: TUIVideoSeatViewResponder?
    var videoSeatViewType: TUIVideoSeatViewType = .equallyDividedType
    var roomInfo: RoomInfo
    var currentUserId: String {
        return TUIRoomEngine.getSelfInfo().userId
    }

    private weak var roomEngine: TUIRoomEngine?
    init(roomEngine: TUIRoomEngine, roomId: String) {
        let tuiRoomInfo = TUIRoomInfo()
        tuiRoomInfo.roomId = roomId
        roomInfo = RoomInfo(roomInfo: tuiRoomInfo)
        super.init()
        self.roomEngine = roomEngine
        initRoomInfo()
        roomEngine.addObserver(self)
    }

    deinit {
        roomEngine?.removeObserver(self)
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
            reloadSeatItems()
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
                  let renderView = viewResponder?.getSeatVideoRenderView(item) {
            startPlayVideo(item: item, renderView: renderView)
        }
    }

    func startPlayVideo(item: VideoSeatItem, renderView: UIView?) {
        if item.userId == currentUserId {
            roomEngine?.setLocalVideoView(streamType: item.streamType, view: renderView)
        } else {
            let renderParams = TRTCRenderParams()
            renderParams.fillMode = (item.streamType == .screenStream) ? .fit : .fill
            let streamType: TRTCVideoStreamType = (item.streamType == .screenStream) ? .sub : .big
            roomEngine?.getTRTCCloud().setRemoteRenderParams(item.userId, streamType: streamType, params: renderParams)
            roomEngine?.setRemoteVideoView(userId: item.userId, streamType: item.streamType, view: renderView)
            roomEngine?.startPlayRemoteVideo(userId: item.userId, streamType: item.streamType, onPlaying: { _ in

            }, onLoading: { _ in

            }, onError: { _, _, _ in

            })
        }
    }

    func stopPlayVideo(item: VideoSeatItem) {
        if item.userId == currentUserId {
            roomEngine?.setLocalVideoView(streamType: item.streamType, view: nil)
        } else {
            roomEngine?.setRemoteVideoView(userId: item.userId, streamType: item.streamType, view: nil)
            roomEngine?.stopPlayRemoteVideo(userId: item.userId, streamType: item.streamType)
        }
    }

    func isNeedStopPlayVideo(item: VideoSeatItem, currentPageIndex: Int) -> Bool {
        // currentPageIndex : 0,1,2,3
        if currentPageIndex < 0 {
            return true
        }
        let cellCount = (videoSeatViewType == .pureAudioType) ? 9 : 6
        guard let seatItemIndex = listSeatItem.firstIndex(where: { $0 == item }) else {
            if currentPageIndex == 0 {
                return false
            }
            return true
        }
        var beginIndex = 0
        var endIndex = 0
        if videoSeatViewType == .speechType {
            if currentPageIndex > 0 {
                beginIndex = 1 + (currentPageIndex - 1) * cellCount
            }
            endIndex = 1 + currentPageIndex * cellCount
        } else {
            beginIndex = currentPageIndex * cellCount
            endIndex = (currentPageIndex + 1) * cellCount
        }
        if beginIndex <= seatItemIndex && seatItemIndex < endIndex {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Private

extension TUIVideoSeatViewModel {
    private func asyncUserInfo(_ seatItem: VideoSeatItem) {
        roomEngine?.getUserInfo(seatItem.userId, onSuccess: { [weak self] userInfo in
            guard let self = self, let userInfo = userInfo else { return }
            seatItem.updateUserInfo(userInfo)
            self.viewResponder?.updateSeatItem(seatItem)
            if userInfo.hasVideoStream {
                self.reloadSeatItems()
            } else {
                self.stopPlayVideo(item: seatItem)
            }
        }, onError: { _, msg in
            debugPrint("asyncUserInfo error: \(msg)")
        })
    }

    private func initRoomInfo() {
        roomEngine?.fetchRoomInfo { [weak self] roomInfo in
            guard let self = self, let roomInfo = roomInfo else { return }
            self.roomInfo = RoomInfo(roomInfo: roomInfo)
            switch self.roomInfo.speechMode {
            case .freeToSpeak:
                let localSeatList: [VideoSeatItem] = []
                self.initUserList(nextSequence: 0, localSeatList: localSeatList)
            case .applySpeakAfterTakingSeat:
                self.initSeatList()
            default: break
            }
        } onError: { code, message in
            debugPrint("getRoomInfo:code:\(code),message:\(message)")
        }
    }

    private func initSeatList() {
        roomEngine?.getSeatList { [weak self] seatList in
            guard let self = self else { return }
            var localSeatList = [VideoSeatItem]()
            for seatInfo in seatList {
                let seatItem = VideoSeatItem(userId: seatInfo.userId ?? "")
                self.asyncUserInfo(seatItem)
                if seatItem.userId == self.roomInfo.ownerId {
                    seatItem.userRole = .roomOwner
                }
                localSeatList.append(seatItem)
            }
            self.videoSeatItems = localSeatList
            self.reloadSeatItems()
        } onError: { code, message in
            debugPrint("getSeatList:code:\(code),message:\(message)")
        }
    }

    private func initUserList(nextSequence: Int, localSeatList: [VideoSeatItem]) {
        roomEngine?.getUserList(nextSequence: nextSequence) { [weak self] list, nextSequence in
            guard let self = self else { return }
            var localSeatList = localSeatList
            list.forEach { userInfo in
                let userItem = VideoSeatItem(userInfo: userInfo)
                localSeatList.append(userItem)
            }
            if nextSequence != 0 {
                self.initUserList(nextSequence: nextSequence, localSeatList: localSeatList)
            }
            self.videoSeatItems = localSeatList
            self.reloadSeatItems()
        } onError: { code, message in
            debugPrint("getUserList:code:\(code),message:\(message)")
        }
    }

    private func addSeatInfo(_ seatInfo: TUISeatInfo) {
        if let userId = seatInfo.userId, let _ = getSeatItem(userId) {
            return
        }
        let seatItem = VideoSeatItem(userId: seatInfo.userId ?? "")
        asyncUserInfo(seatItem)
        videoSeatItems.append(seatItem)
        reloadSeatItems()
    }

    private func addUserInfo(_ userInfo: TUIUserInfo) {
        if let userItem = getSeatItem(userInfo.userId) {
            userItem.updateUserInfo(userInfo)
            viewResponder?.updateSeatItem(userItem)
        } else {
            let seatItem = VideoSeatItem(userInfo: userInfo)
            videoSeatItems.append(seatItem)
            reloadSeatItems()
        }
    }

    private func removeSeatItem(_ userId: String) {
        if shareItem?.userId == userId, let seatItem = shareItem {
            stopPlayVideo(item: seatItem)
        }

        if speakerItem?.userId == userId, let seatItem = speakerItem {
            stopPlayVideo(item: seatItem)
        }
        guard let seatItemIndex = videoSeatItems.firstIndex(where: { $0.userId == userId }) else { return }
        let seatItem = videoSeatItems.remove(at: seatItemIndex)
        stopPlayVideo(item: seatItem)
        reloadSeatItems()
    }

    private func getSeatItem(_ userId: String) -> VideoSeatItem? {
        return videoSeatItems.first(where: { $0.userId == userId })
    }

    private func sortSeatItems() {
        //  自己在第二位
        if let currentItemIndex = videoSeatItems.firstIndex(where: { $0.userId == self.currentUserId }) {
            let currentItem = videoSeatItems.remove(at: currentItemIndex)
            videoSeatItems.insert(currentItem, at: 0)
        }
        // 房主永远在第一位
        if let roomOwnerItemIndex = videoSeatItems.firstIndex(where: { $0.userRole == .roomOwner }) {
            let roomOwnerItem = videoSeatItems.remove(at: roomOwnerItemIndex)
            videoSeatItems.insert(roomOwnerItem, at: 0)
        }
    }

    private func findCurrentSpeaker(list: [VideoSeatItem]) -> VideoSeatItem? {
        var array = Array(list)
        array.sort { leftItem, rightItem in
            if leftItem.hasAudioStream == rightItem.hasAudioStream {
                return leftItem.audioVolume > rightItem.audioVolume
            } else {
                return leftItem.hasAudioStream && !rightItem.hasAudioStream
            }
        }
        var currentSpeakerItem: VideoSeatItem?
        if shareItem == nil, let speech = listSeatItem.first {
            currentSpeakerItem = array.first(where: { $0.userId != speech.userId })
        } else {
            currentSpeakerItem = array.first
        }
        return currentSpeakerItem
    }

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
            if item.hasScreenStream {
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
            if let currentSpeakerItem = findCurrentSpeaker(list: listSeatItem)?.cloneSpeaker(), currentSpeakerItem.hasAudioStream {
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
            self.refreshListSeatItem()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.viewResponder?.reloadData()
            CATransaction.commit()
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
}

extension TUIVideoSeatViewModel: TUIRoomObserver {
    func onUserAudioStateChanged(userId: String, hasAudio: Bool, reason: TUIChangeReason) {
        guard let seatItem = getSeatItem(userId) else {
            return
        }
        // 同步刷新 分享和speaker的view的音量
        seatItem.hasAudioStream = hasAudio
        updateSeatVolume(item: seatItem)
    }

    public func onUserVoiceVolumeChanged(volumeMap: [String: NSNumber]) {
        if volumeMap.count <= 0 {
            return
        }
        for (userId, volume) in volumeMap {
            guard let seatItem = getSeatItem(userId) else { continue }
            seatItem.audioVolume = volume.intValue
            updateSeatVolume(item: seatItem)
        }

        if videoSeatViewType == .speechType {
            guard let currentSpeakerItem = findCurrentSpeaker(list: listSeatItem)?.cloneSpeaker(), currentSpeakerItem.hasAudioStream else { return }
            if speakerItem?.userId == currentSpeakerItem.userId {
                viewResponder?.updateMiniscreenVolume(currentSpeakerItem)
            } else {
                viewResponder?.updateMiniscreen(currentSpeakerItem)
            }
            speakerItem = currentSpeakerItem
        }
    }

    public func onUserVideoStateChanged(userId: String, streamType: TUIVideoStreamType, hasVideo: Bool, reason: TUIChangeReason) {
        guard var seatItem = getSeatItem(userId) else {
            return
        }
        if streamType == .cameraStream {
            seatItem.hasVideoStream = hasVideo
            viewResponder?.updateSeatItem(seatItem)
        } else if streamType == .screenStream {
            seatItem.hasScreenStream = hasVideo
            if let item = shareItem, item.userId == userId, item.streamType == .screenStream {
                seatItem = item
            }
        }
        if hasVideo {
            startPlayVideo(item: seatItem, renderView: viewResponder?.getSeatVideoRenderView(seatItem))
        } else {
            stopPlayVideo(item: seatItem)
        }
        reloadSeatItems()
    }

    // seatList: 当前麦位列表  seated: 新增上麦的用户列表 left: 下麦的用户列表
    public func onSeatListChanged(seatList: [TUISeatInfo], seated: [TUISeatInfo], left: [TUISeatInfo]) {
        for leftSeat in left {
            if let userId = leftSeat.userId {
                removeSeatItem(userId)
            }
        }
        for seatInfo in seatList {
            addSeatInfo(seatInfo)
        }
        reloadSeatItems()
    }

    public func onUserRoleChanged(userId: String, userRole: TUIRole) {
        guard let seatItem = getSeatItem(userId) else { return }
        seatItem.userRole = userRole
        reloadSeatItems()
    }

    public func onRemoteUserEnterRoom(roomId: String, userInfo: TUIUserInfo) {
        switch roomInfo.speechMode {
        case .freeToSpeak:
            addUserInfo(userInfo)
        case .applySpeakAfterTakingSeat:
            break
        default: break
        }
    }

    public func onRemoteUserLeaveRoom(roomId: String, userInfo: TUIUserInfo) {
        removeSeatItem(userInfo.userId)
    }
}
