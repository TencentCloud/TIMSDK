//
//  EngineManager.swift
//  TUIRoomKit
//
//  Created by WesleyLei on 2022/9/22.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore
import TUIRoomEngine
#if TXLiteAVSDK_TRTC
import TXLiteAVSDK_TRTC
#elseif TXLiteAVSDK_Professional
import TXLiteAVSDK_Professional
#endif

class EngineManager: NSObject {
    private static var _shared: EngineManager?
    class func createInstance() -> EngineManager {
        guard let instance = _shared else {
            let engineManager = EngineManager()
            _shared = engineManager
            return engineManager
        }
        return instance
    }
    private(set) lazy var store: RoomStore = {
        let store = RoomStore()
        return store
    }()
    private(set) lazy var roomEngine: TUIRoomEngine = {
        let roomEngine = TUIRoomEngine()
        roomEngine.addObserver(eventDispatcher)
        return roomEngine
    }()
    private lazy var eventDispatcher: RoomEventDispatcher = {
        let eventDispatcher = RoomEventDispatcher()
        return eventDispatcher
    }()
    private let timeOutNumber: Double = 10
    private let rootRouter: RoomRouter = RoomRouter.shared
    private var isLoginEngine: Bool = false
    private let appGroupString: String = "com.tencent.TUIRoomTXReplayKit-Screen"
    
    override private init() {
        super.init()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    func setSelfInfo(userName: String, avatarURL: String, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.currentUser.userName = userName
        store.currentUser.avatarUrl = avatarURL
        TUIRoomEngine.setSelfInfo(userName: userName, avatarUrl: avatarURL) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
            debugPrint("---setSelfInfo,code:\(code),message:\(message)")
        }
    }
    
    func createRoom(roomInfo: TUIRoomInfo, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        if !isLoginEngine {
            self.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID() ?? "", userSig: TUILogin.getUserSig() ?? "")
            { [weak self] in
                guard let self = self else { return }
                self.isLoginEngine = true
                self.createEngineRoom(roomInfo: roomInfo, onSuccess: onSuccess, onError: onError)
            } onError: { code, message in
                onError(code, message)
            }
        } else {
            createEngineRoom(roomInfo: roomInfo, onSuccess: onSuccess, onError: onError)
        }
    }
    
    func enterRoom(roomId: String, enableAudio: Bool, enableVideo: Bool, isSoundOnSpeaker: Bool,
                   onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.videoSetting.isCameraOpened = enableVideo
        store.audioSetting.isSoundOnSpeaker = isSoundOnSpeaker
        setFramework()
        //先判断是否登录
        if !isLoginEngine {
            self.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID() ?? "", userSig: TUILogin.getUserSig() ?? "")
            { [weak self] in
                guard let self = self else { return }
                self.isLoginEngine = true
                self.enterEngineRoom(roomId: roomId, enableAudio: enableAudio, onSuccess: onSuccess, onError: onError)
            } onError: { code, message in
                onError(code, message)
            }
        } else {
            enterEngineRoom(roomId: roomId, enableAudio: enableAudio, onSuccess: onSuccess, onError: onError)
        }
    }
    
    func exitRoom(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.exitRoom(syncWaiting: false) { [weak self] in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ExitedRoom, param: [:])
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    func destroyRoom(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.destroyRoom { [weak self] in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DestroyedRoom, param: [:])
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    func destroyEngineManager() {
        roomEngine.removeObserver(eventDispatcher)
        EngineManager._shared = nil
    }
    
    //关闭本地音频
    func muteLocalAudio() {
        roomEngine.muteLocalAudio()
    }
    
    //打开本地音频
    func unmuteLocalAudio(onSuccess:TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.unmuteLocalAudio {
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    //打开本地麦克风
    func openLocalMicrophone(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        let actionBlock = { [weak self] in
            guard let self = self else { return }
            self.roomEngine.openLocalMicrophone(self.store.audioSetting.audioQuality) { [weak self] in
                guard let self = self else { return }
                self.store.audioSetting.isMicOpened = true
                onSuccess?()
            } onError: { code, message in
                onError?(code, message)
            }
        }
        if RoomCommon.checkAuthorMicStatusIsDenied() {
            actionBlock()
        } else {
            RoomCommon.micStateActionWithPopCompletion { granted in
                if granted {
                    actionBlock()
                }
            }
        }
    }
    
    //关闭本地摄像头
    func closeLocalCamera() {
        store.videoSetting.isCameraOpened = false
        roomEngine.closeLocalCamera()
    }
    
    //打开本地摄像头
    func openLocalCamera(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        let actionBlock = { [weak self] in
            guard let self = self else { return }
            self.store.videoSetting.isCameraOpened = true
            self.roomEngine.openLocalCamera(isFront: self.store.videoSetting.isFrontCamera, quality:
                                                self.store.videoSetting.videoQuality) {
                onSuccess?()
            } onError: { code, message in
                onError?(code, message)
            }
        }
        if RoomCommon.checkAuthorCamaraStatusIsDenied() {
            actionBlock()
        } else {
            RoomCommon.cameraStateActionWithPopCompletion { granted in
                if granted {
                    actionBlock()
                }
            }
        }
    }
    
    func switchCamera() {
        store.videoSetting.isFrontCamera = !store.videoSetting.isFrontCamera
        roomEngine.getDeviceManager().switchCamera(store.videoSetting.isFrontCamera)
    }
    
    func switchMirror() {
        store.videoSetting.isMirror = !store.videoSetting.isMirror
        let params = TRTCRenderParams()
        params.mirrorType = store.videoSetting.isMirror ? .enable : .disable
        setLocalRenderParams(params: params)
    }
    
    func muteAllAudioAction(isMute: Bool, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.roomInfo.isMicrophoneDisableForAllUser = isMute
        roomEngine.disableDeviceForAllUserByAdmin(device: .microphone, isDisable:
                                                    store.roomInfo.isMicrophoneDisableForAllUser) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    func muteAllVideoAction(isMute: Bool, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.roomInfo.isCameraDisableForAllUser = isMute
        roomEngine.disableDeviceForAllUserByAdmin(device: .camera, isDisable:
                                                    store.roomInfo.isCameraDisableForAllUser) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    //主持人/管理员 邀请用户上麦
    func takeUserOnSeatByAdmin(userId: String, timeout: Double,
                               onAccepted: TUIRequestAcceptedBlock? = nil,
                               onRejected: TUIRequestRejectedBlock? = nil,
                               onCancelled: TUIRequestCancelledBlock? =  nil,
                               onTimeout: TUIRequestTimeoutBlock? = nil,
                               onError: TUIRequestErrorBlock? = nil) {
        store.extendedInvitationList.append(userId)
        roomEngine.takeUserOnSeatByAdmin(-1, userId: userId, timeout: timeout) { [weak self] requestId, userId in
            guard let self = self else { return }
            self.store.extendedInvitationList.removeAll(where: { $0 == userId })
            onAccepted?(requestId, userId)
        } onRejected: { [weak self] requestId, userId, message in
            guard let self = self else { return }
            self.store.extendedInvitationList.removeAll(where: { $0 == userId })
            onRejected?( requestId, userId, message)
        } onCancelled: { [weak self] requestId, userId in
            guard let self = self else { return }
            self.store.extendedInvitationList.removeAll(where: { $0 == userId })
            onCancelled?(requestId, userId)
        } onTimeout: { [weak self] requestId, userId in
            guard let self = self else { return }
            self.store.extendedInvitationList.removeAll(where: { $0 == userId })
            onTimeout?(requestId, userId)
        } onError: { [weak self] requestId, userId, code, message in
            guard let self = self else { return }
            self.store.extendedInvitationList.removeAll(where: { $0 == userId })
            onError?(requestId, userId, code, message)
        }
    }
    
    func setAudioRoute(route: TRTCAudioRoute) {
        store.audioSetting.isSoundOnSpeaker = route == .modeSpeakerphone
        roomEngine.getTRTCCloud().setAudioRoute(route)
    }
    
    //上麦
    func takeSeat(onAccepted: TUIRequestAcceptedBlock? = nil,
                  onRejected: TUIRequestRejectedBlock? = nil,
                  onCancelled: TUIRequestCancelledBlock? = nil,
                  onTimeout: TUIRequestTimeoutBlock? = nil,
                  onError: TUIRequestErrorBlock? = nil) -> TUIRequest {
        let request = self.roomEngine.takeSeat(-1, timeout: self.timeOutNumber) { [weak self] requestId, userId in
            guard let self = self else { return }
            self.store.currentUser.isOnSeat = true
            onAccepted?(requestId, userId)
        } onRejected: { requestId, userId, message in
            onRejected?(requestId, userId, message)
        } onCancelled: { requestId, userId in
            onCancelled?(requestId, userId)
        } onTimeout: { requestId, userId in
            onTimeout?(requestId, userId)
        } onError: { requestId, userId, code, message in
            onError?(requestId, userId, code, message)
        }
        return request
    }
    
    func fetchRoomInfo(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.fetchRoomInfo { [weak self] roomInfo in
            guard let self = self, let roomInfo = roomInfo else { return }
            self.store.roomInfo = roomInfo
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
            debugPrint("fetchRoomInfo,code:\(code), message:\(message)")
        }
    }
    
    func setLocalRenderParams(params: TRTCRenderParams) {
        roomEngine.getTRTCCloud().setLocalRenderParams(params)
    }
    
    func setGSensorMode(mode: TRTCGSensorMode) {
        roomEngine.getTRTCCloud().setGSensorMode(mode)
    }
    
    func setLocalVideoView(streamType: TUIVideoStreamType, view: UIView?) {
        roomEngine.setLocalVideoView(streamType: streamType, view: view)
    }
    
    //修改用户角色（只有管理员或房主能够调用）
    func changeUserRole(userId: String, role: TUIRole, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.changeUserRole(userId: userId, role: role, onSuccess: onSuccess, onError: onError)
    }
    
    //回复请求
    func responseRemoteRequest(_ requestId: String, agree: Bool, onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.responseRemoteRequest(requestId, agree: agree) {
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    //获取成员信息
    func getUserInfo(_ userId: String, onSuccess: @escaping TUIUserInfoBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.getUserInfo(userId, onSuccess: onSuccess, onError: onError)
    }
    
    //结束屏幕分享
    func stopScreenCapture() {
        roomEngine.stopScreenCapture()
    }
    
    func setVideoEncoderParam(_ param: TRTCVideoEncParam) {
        roomEngine.getTRTCCloud().setVideoEncoderParam(param)
    }
    
    //取消请求
    func cancelRequest(_ requestId: String, onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.cancelRequest(requestId) {
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    //下麦
    func leaveSeat(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.leaveSeat {
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    //开始屏幕分享
    func startScreenCapture() {
        roomEngine.startScreenCapture(appGroup: appGroupString)
    }
    
    //停止播放远端用户视频
    func stopPlayRemoteVideo(userId: String, streamType: TUIVideoStreamType) {
        roomEngine.stopPlayRemoteVideo(userId: userId, streamType: streamType)
    }
    
    //设置远端用户视频渲染的视图控件
    func setRemoteVideoView(userId: String, streamType: TUIVideoStreamType, view: UIView?) {
        roomEngine.setRemoteVideoView(userId: userId, streamType: streamType, view: view)
    }
    
    //开始播放远端用户视频
    func startPlayRemoteVideo(userId: String, streamType: TUIVideoStreamType, onSuccess: TUISuccessBlock? = nil,
                              onLoading: TUIPlayOnLoadingBlock? = nil, onError: TUIPlayOnErrorBlock? = nil) {
        roomEngine.startPlayRemoteVideo(userId: userId, streamType: streamType, onPlaying: { _ in
            guard let onSuccess = onSuccess else { return }
            onSuccess()
        }, onLoading: { userId in
            guard let onLoading = onLoading else { return }
            onLoading(userId)
        }, onError: { userId, code, message in
            guard let onError = onError else { return }
            onError(userId, code, message)
        })
    }
    
    func setAudioCaptureVolume(_ captureVolume: Int) {
        store.audioSetting.captureVolume = captureVolume
        roomEngine.getTRTCCloud().setAudioCaptureVolume(captureVolume)
    }
    
    func setAudioPlayoutVolume(_ playVolume: Int) {
        store.audioSetting.playVolume = playVolume
        roomEngine.getTRTCCloud().setAudioPlayoutVolume(playVolume)
    }
    
    func enableAudioVolumeEvaluation(isVolumePrompt: Bool) {
        store.audioSetting.volumePrompt = isVolumePrompt
        if isVolumePrompt {
            roomEngine.getTRTCCloud().enableAudioVolumeEvaluation(300, enable_vad: true)
        } else {
            roomEngine.getTRTCCloud().enableAudioVolumeEvaluation(0, enable_vad: false)
        }
    }
    
    //关闭远端用户媒体设备（只有管理员或房主能够调用）
    func closeRemoteDeviceByAdmin(userId: String, device: TUIMediaDevice, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.closeRemoteDeviceByAdmin(userId: userId, device: device, onSuccess: onSuccess, onError: onError)
    }
    
    //请求远端用户打开媒体设备（只有管理员或房主能够调用）
    func openRemoteDeviceByAdmin(userId: String, device: TUIMediaDevice,
                                 onAccepted: TUIRequestAcceptedBlock? = nil,
                                 onRejected: TUIRequestRejectedBlock? = nil,
                                 onCancelled: TUIRequestCancelledBlock? = nil,
                                 onTimeout: TUIRequestTimeoutBlock? = nil,
                                 onError: TUIRequestErrorBlock? = nil) {
        roomEngine.openRemoteDeviceByAdmin(userId: userId, device: device, timeout: timeOutNumber, onAccepted: { requestId, userId in
            onAccepted?(requestId, userId)
        }, onRejected: { requestId, userId, message in
            onRejected?(requestId, userId, message)
        }, onCancelled: { requestId, userId in
            onCancelled?(requestId, userId)
        }, onTimeout: { requestId, userId in
            onTimeout?(requestId, userId)
        }) { requestId, userId, code, message in
            onError?(requestId, userId, code, message)
        }
    }
    
    //禁用远端用户的发送文本消息能力（只有管理员或房主能够调用）
    func disableSendingMessageByAdmin(userId: String, isDisable: Bool, onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.disableSendingMessageByAdmin(userId: userId, isDisable: isDisable) {
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    //主持人/管理员 将用户踢下麦
    func kickUserOffSeatByAdmin(userId: String, onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.kickUserOffSeatByAdmin(-1, userId: userId) {
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    //将远端用户踢出房间（只有管理员或房主能够调用）
    func kickRemoteUserOutOfRoom(userId: String, onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        roomEngine.kickRemoteUserOutOfRoom(userId) {
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    //初始化用户列表
    func initUserList(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        self.getUserList(nextSequence: 0, localUserList: []) { [weak self] in
            guard let self = self else { return }
            if self.store.roomInfo.speechMode == .applySpeakAfterTakingSeat {
                self.getSeatList {
                    onSuccess?()
                } onError: { code, message in
                    onError?(code, message)
                }
            } else {
                onSuccess?()
            }
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    //赠加举手用户
    func addInviteSeatUser(userItem: UserEntity, request: TUIRequest) {
        store.inviteSeatList.append(userItem)
        store.inviteSeatMap[request.userId] = request.requestId
    }
    
    //删除举手用户
    func deleteInviteSeatUser(_ userId: String) {
        store.inviteSeatList = store.inviteSeatList.filter { userModel in
            userModel.userId != userId
        }
        store.inviteSeatMap.removeValue(forKey: userId)
    }
    
    //增加房间用户
    func addUserItem(_ userItem: UserEntity) {
        guard getUserItem(userItem.userId) == nil else { return }
        if userItem.userName.isEmpty {
            userItem.userName = userItem.userId
        }
        store.attendeeList.append(userItem)
    }
    //删除房间用户
    func deleteUserItem(_ userId: String) {
        store.attendeeList = store.attendeeList.filter({ userItem in
            userItem.userId != userId
        })
    }
    
    //增加麦上用户
    func addSeatItem(_ userItem: UserEntity) {
        guard getSeatItem(userItem.userId) == nil else { return }
        store.seatList.append(userItem)
    }
    
    //删除麦上用户
    func deleteSeatItem(_ userId: String) {
        store.seatList = store.seatList.filter({ userItem in
            userItem.userId != userId
        })
    }
    
    //更新本地视频编码质量设置
    func updateVideoQuality(quality: TUIVideoQuality) {
        roomEngine.updateVideoQuality(quality)
    }
    
    func enableGravitySensor(enable: Bool) {
        roomEngine.enableGravitySensor(enable: enable)
    }
    
    func setVideoResolutionMode(streamType: TUIVideoStreamType, resolutionMode: TUIResolutionMode) {
        roomEngine.setVideoResolutionMode(streamType: streamType, resolutionMode: resolutionMode)
    }
    
    func changeRaiseHandNoticeState(isShown: Bool) {
        store.isShownRaiseHandNotice = isShown
    }
    
    func setRemoteRenderParams(userId: String, streamType: TRTCVideoStreamType, params: TRTCRenderParams) {
        roomEngine.getTRTCCloud().setRemoteRenderParams(userId, streamType: streamType, params: params)
    }
}

// MARK: - Private
extension EngineManager {
    private func login(sdkAppId: Int, userId: String, userSig: String, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        V2TIMManager.sharedInstance().initSDK(Int32(sdkAppId), config: V2TIMSDKConfig())
        store.currentUser.userId = userId
        TUIRoomEngine.login(sdkAppId: sdkAppId, userId: userId, userSig: userSig) { [weak self] in
            guard let self = self else { return }
            self.isLoginEngine = true
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    private func logout(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        guard isLoginEngine else { return }
        TUIRoomEngine.logout { [weak self] in
            guard let self = self else { return }
            self.isLoginEngine = false
            onSuccess?()
        } onError: { code, message in
            onError?(code, message)
        }
    }
    
    private func createEngineRoom(roomInfo: TUIRoomInfo, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        guard !store.isEnteredRoom else {
            if store.roomInfo.roomId == roomInfo.roomId {
                RoomVideoFloatView.dismiss()
                onSuccess()
            } else {
                onError(.failed, .inAnotherRoomText)
            }
            return
        }
        self.store.roomInfo = roomInfo
        self.roomEngine.createRoom(roomInfo) {
            onSuccess()
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    private func enterEngineRoom(roomId: String, enableAudio: Bool, onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        guard !store.isEnteredRoom else {
            if store.roomInfo.roomId == roomId {
                RoomVideoFloatView.dismiss()
                EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ShowRoomMainView, param: [:])
                onSuccess()
            } else {
                onError(.failed, .inAnotherRoomText)
            }
            return
        }
        roomEngine.enterRoom(roomId) { [weak self] roomInfo in
            guard let self = self else { return }
            guard let roomInfo = roomInfo else { return }
            //更新store存储的进房数据
            self.store.roomInfo = roomInfo
            self.store.initialRoomCurrentUser()
            self.store.isEnteredRoom = true
            self.store.timeStampOnEnterRoom = Int(Date().timeIntervalSince1970)
            //初始化用户列表
            self.initUserList()
            //初始化视频设置
            self.initLocalVideoState()
            //如果是举手发言房间的房主，需要先上麦再跳转到会议主页面
            if roomInfo.speechMode == .applySpeakAfterTakingSeat, self.store.currentUser.userId == roomInfo.ownerId {
                self.takeSeat() { [weak self] _,_ in
                    guard let self = self else { return }
                    self.showRoomViewController(roomId: roomInfo.roomId)
                    self.operateLocalMicrophone(enableAudio: enableAudio)
                    onSuccess()
                } onError: { [weak self] _, _, code, message in
                    guard let self = self else { return }
                    self.store.currentUser.userId == roomInfo.ownerId ? self.destroyRoom() : self.exitRoom()
                    self.rootRouter.dismissAllRoomPopupViewController()
                    self.rootRouter.popToRoomEntranceViewController()
                    onError(code, message)
                }
            } else {
                //跳转到会议主界面
                if self.store.isShowRoomMainViewAutomatically {
                    self.showRoomViewController(roomId: roomInfo.roomId)
                }
                //操作麦克风
                self.operateLocalMicrophone(enableAudio: enableAudio)
                onSuccess()
            }
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    private func showRoomViewController(roomId: String) {
        self.rootRouter.pushMainViewController(roomId: roomId)
    }
    
    private func isPushLocalAudioStream(enableAudio: Bool) -> Bool {
        if !enableAudio {
            return false
        }
        if store.roomInfo.isMicrophoneDisableForAllUser, store.currentUser.userId != store.roomInfo.ownerId {
            return false
        }
        if store.roomInfo.speechMode == .applySpeakAfterTakingSeat, store.currentUser.userId != store.roomInfo.ownerId {
            return false
        }
        return true
    }
    
    //进房后操作麦克风
    private func operateLocalMicrophone(enableAudio: Bool ,onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        if isPushLocalAudioStream(enableAudio: enableAudio) {
            openLocalMicrophone()
        } else if RoomCommon.checkAuthorMicStatusIsDenied() {
            //检查麦克风权限
            muteLocalAudio()
            openLocalMicrophone()
        }
    }
    
    //进房后视频设置
    private func initLocalVideoState() {
        setVideoParam()
        updateVideoQuality(quality: store.videoSetting.videoQuality)
        enableGravitySensor(enable: true)
        setGSensorMode(mode: .uiFixLayout)
        let resolutionMode: TUIResolutionMode = isLandscape ? .landscape : .portrait
        setVideoResolutionMode(streamType: .cameraStream, resolutionMode: resolutionMode)
    }
    
    private func setVideoParam() {
        let param = TRTCVideoEncParam()
        param.videoBitrate = Int32(store.videoSetting.videoBitrate)
        param.videoFps = Int32(store.videoSetting.videoFps)
        param.enableAdjustRes = true
        setVideoEncoderParam(param)
        let params = TRTCRenderParams()
        params.fillMode = .fill
        params.rotation = ._0
        setLocalRenderParams(params: params)
    }
    
    //获取用户列表
    private func getUserList(nextSequence: Int, localUserList: [UserEntity], onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.getUserList(nextSequence: nextSequence) { [weak self] list, nextSequence in
            guard let self = self else { return }
            var localUserList = localUserList
            list.forEach { userInfo in
                if userInfo.userName.isEmpty {
                    userInfo.userName = userInfo.userId
                }
                let userModel = UserEntity()
                userModel.update(userInfo: userInfo)
                localUserList.append(userModel)
            }
            if nextSequence != 0 {
                self.getUserList(nextSequence: nextSequence, localUserList: localUserList, onSuccess: onSuccess, onError: onError)
            } else {
                self.store.attendeeList = localUserList
                onSuccess()
                if self.store.roomInfo.speechMode != .applySpeakAfterTakingSeat {
                    EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewVideoSeatView, param: [:])
                }
                EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
            }
        } onError: { code, message in
            onError(code, message)
            debugPrint("getUserList:code:\(code),message:\(message)")
        }
    }
    
    //获取麦上用户列表
    private func getSeatList(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        roomEngine.getSeatList { [weak self] seatList in
            guard let self = self else { return }
            var localSeatList = [UserEntity]()
            for seatInfo in seatList {
                var userModel = UserEntity()
                userModel.userId = seatInfo.userId ?? ""
                if let user = self.store.attendeeList.first(where: { $0.userId == seatInfo.userId }) {
                    userModel = user
                }
                userModel.isOnSeat = true
                localSeatList.append(userModel)
            }
            self.store.seatList = localSeatList
            onSuccess()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewSeatList, param: [:])
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewVideoSeatView, param: [:])
        } onError: { code, message in
            onError(code, message)
            debugPrint("getSeatList:code:\(code),message:\(message)")
        }
    }
    
    private func getUserItem(_ userId: String) -> UserEntity? {
        return store.attendeeList.first(where: {$0.userId == userId})
    }
    
    private func getSeatItem(_ userId: String) -> UserEntity? {
        return store.seatList.first(where: { $0.userId == userId })
    }
}
// MARK: - TUIExtensionProtocol

extension EngineManager: TUIExtensionProtocol {
    func getExtensionInfo(_ key: String, param: [AnyHashable: Any]?) -> [AnyHashable: Any] {
        guard let param = param else {
            return [:]
        }
        
        guard let roomId: String = param["roomId"] as? String else {
            return [:]
        }
        
        if key == gRoomEngineKey {
            return [key: roomEngine]
        } else if key == gRoomInfoKey {
            return [key: store.roomInfo]
        } else if key == gLocalUserInfoKey {
            return [key: store.currentUser]
        } else {
            return [:]
        }
    }
}


// MARK: - setFramework
extension EngineManager {
    fileprivate static let TUIRoomKitFrameworkValue = 1
    fileprivate static let TUIRoomKitComponentValue = 18
    fileprivate static let IMComponentValue = 19
    fileprivate static let TUIRoomKitLanguageValue = 3
    private func setFramework() {
        let componentValue = store.isImAccess ? EngineManager.IMComponentValue : EngineManager.TUIRoomKitComponentValue
        let jsonStr = """
            {
                "api":"setFramework",
                "params":{
                    "framework":\(EngineManager.TUIRoomKitFrameworkValue),
                    "component":\(componentValue),
                    "language":\(EngineManager.TUIRoomKitLanguageValue)
                }
            }
        """
        roomEngine.callExperimentalAPI(jsonStr: jsonStr)
    }
}

private extension String {
    static var inAnotherRoomText: String {
        localized("TUIRoom.in.another.room")
    }
}
