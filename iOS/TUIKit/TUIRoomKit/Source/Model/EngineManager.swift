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
    let timeOutNumber: Double = 0
    let rootRouter: RoomRouter = RoomRouter.shared
    var isLoginEngine: Bool = false
    let appGroupString: String = "com.tencent.TUIRoomTXReplayKit-Screen"
    
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
        store.roomInfo = roomInfo
        let createRoomBlock = { [weak self] in
            guard let self = self else { return }
            self.roomEngine.createRoom(roomInfo) {
                onSuccess()
            } onError: { code, message in
                onError(code, message)
            }
        }
        if !isLoginEngine {
            self.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID() ?? "", userSig: TUILogin.getUserSig() ?? "")
            { [weak self] in
                guard let self = self else { return }
                self.isLoginEngine = true
                createRoomBlock()
            } onError: { code, message in
                onError(code, message)
            }
        } else {
            createRoomBlock()
        }
    }
    
    func enterRoom(roomId: String, enableMic: Bool, enableCamera: Bool, isSoundOnSpeaker: Bool,
                   onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        store.videoSetting.isCameraOpened = enableCamera
        store.audioSetting.isMicOpened = enableMic
        store.audioSetting.isSoundOnSpeaker = isSoundOnSpeaker
        setFramework()
        if !isLoginEngine {
            self.login(sdkAppId: Int(TUILogin.getSdkAppID()), userId: TUILogin.getUserID() ?? "", userSig: TUILogin.getUserSig() ?? "")
            { [weak self] in
                guard let self = self else { return }
                self.isLoginEngine = true
                self.enterRoom(roomId: roomId, enableMic: enableMic, enableCamera: enableCamera, isSoundOnSpeaker: isSoundOnSpeaker,
                               onSuccess: onSuccess, onError: onError)
            } onError: { code, message in
                onError(code, message)
            }
            return
        }
        self.roomEngine.enterRoom(roomId) { [weak self] roomInfo in
            guard let self = self else { return }
            guard let roomInfo = roomInfo else { return }
            //更新store存储的进房数据
            self.store.roomInfo = roomInfo
            self.store.initialRoomCurrentUser()
            self.store.isEnteredRoom = true
            self.store.timeStampOnEnterRoom = Int(Date().timeIntervalSince1970)
            //初始化用户列表
            self.initUserList { [weak self] in
                guard let self = self else { return }
                //打开麦克风
                self.operateLocalMicrophone()
                    if self.store.isShowRoomMainViewAutomatically {
                        //跳转到会议主界面
                        self.showRoomViewController(roomId: roomInfo.roomId)
                    }
            } onError: {  code, message in
                onError(code, message)
            }
        } onError: { code, message in
            onError(code, message)
        }
    }
    
    func exitRoom(onSuccess: TUISuccessBlock?, onError: TUIErrorBlock?) {
        roomEngine.getTRTCCloud().stopAllRemoteView()
        RoomFloatView.dismiss()
        roomEngine.exitRoom(syncWaiting: false) { [weak self] in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ExitedRoom, param: ["isExited":true])
            onSuccess?()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ExitedRoom, param: ["isExited":false])
            onError?(code, message)
        }
        TRTCCloud.destroySharedIntance()
    }
    
    func destroyRoom(onSuccess: TUISuccessBlock?, onError: TUIErrorBlock?) {
        roomEngine.getTRTCCloud().stopAllRemoteView()
        RoomFloatView.dismiss()
        roomEngine.destroyRoom { [weak self] in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DestroyedRoom, param: ["isDestroyed":true])
            onSuccess?()
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            self.destroyEngineManager()
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DestroyedRoom, param: ["isDestroyed":false])
            onError?(code, message)
        }
        TRTCCloud.destroySharedIntance()
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
        let actionBlock = { [weak self] in
            guard let self = self else { return }
            self.roomEngine.unmuteLocalAudio {
                onSuccess?()
            } onError: { code, message in
                onError?(code, message)
            }
        }
        if store.audioSetting.isMicDeviceOpened {
            actionBlock()
        } else {
            openLocalMicrophone()
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
        roomEngine.takeUserOnSeatByAdmin(-1, userId: userId, timeout: timeout) { requestId, userId in
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
    }
    
    func setAudioRoute(route: TRTCAudioRoute) {
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
    func initUserList(onSuccess: @escaping TUISuccessBlock, onError: @escaping TUIErrorBlock) {
        self.getUserList(nextSequence: 0, localUserList: []) { [weak self] in
            guard let self = self else { return }
            if self.store.roomInfo.speechMode == .applySpeakAfterTakingSeat {
                self.getSeatList {
                    onSuccess()
                } onError: { code, message in
                    onError(code, message)
                }
            } else {
                onSuccess()
            }
        } onError: { code, message in
            onError(code, message)
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
    
    private func showRoomViewController(roomId: String) {
        self.rootRouter.pushMainViewController(roomId: roomId)
    }
    
    private func operateLocalMicrophone(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        switch self.store.roomInfo.speechMode {
        case .freeToSpeak:
            if self.store.audioSetting.isMicOpened && (!self.store.roomInfo.isMicrophoneDisableForAllUser
                                                       || self.store.currentUser.userId == self.store.roomInfo.ownerId) {
                self.openLocalMicrophone()
            }
            onSuccess?()
        case .applyToSpeak:
            if self.store.currentUser.userId == self.store.roomInfo.ownerId, self.store.audioSetting.isMicOpened {
                self.openLocalMicrophone()
            }
            onSuccess?()
        case .applySpeakAfterTakingSeat:
            //如果用户是房主，直接上麦
            if self.store.currentUser.userId == self.store.roomInfo.ownerId {
                self.takeSeat {_,_ in
                    if self.store.audioSetting.isMicOpened {
                        self.openLocalMicrophone()
                    }
                    onSuccess?()
                } onError: { [weak self] requestId, userId, code, message  in
                    guard let self = self else { return }
                    self.destroyRoom(onSuccess: nil, onError: nil)
                    self.rootRouter.dismissAllRoomPopupViewController()
                    self.rootRouter.popToRoomEntranceViewController()
                    onError?(code, message)
                }
            } else { //如果是观众，进入举手发言房间不上麦
                onSuccess?()
            }
        default:
            if self.store.currentUser.userId == self.store.roomInfo.ownerId {
                self.destroyRoom(onSuccess: nil, onError: nil)
            } else {
                self.exitRoom(onSuccess: nil, onError: nil)
            }
            self.rootRouter.dismissAllRoomPopupViewController()
            self.rootRouter.popToRoomEntranceViewController()
            onError?(.failed, "speechMode is wrong")
        }
    }
    
    //打开本地麦克风
    private func openLocalMicrophone(onSuccess: TUISuccessBlock? = nil, onError: TUIErrorBlock? = nil) {
        let actionBlock = { [weak self] in
            guard let self = self else { return }
            self.store.audioSetting.isMicDeviceOpened = true
            self.roomEngine.openLocalMicrophone(self.store.audioSetting.audioQuality) {
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
    fileprivate static let TUIRoomKitLanguageValue = 3
    private func setFramework() {
        let jsonStr = """
            {
                "api":"setFramework",
                "params":{
                    "framework":\(EngineManager.TUIRoomKitFrameworkValue),
                    "component":\(EngineManager.TUIRoomKitComponentValue),
                    "language":\(EngineManager.TUIRoomKitLanguageValue)
                }
            }
        """
        roomEngine.callExperimentalAPI(jsonStr: jsonStr)
    }
}
