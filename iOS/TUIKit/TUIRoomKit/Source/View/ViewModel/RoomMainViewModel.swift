//
//  RoomMainViewModel.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/27.
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

protocol RoomMainViewResponder: AnyObject {
    func showSelfBecomeRoomOwnerAlert()
    func showBeautyView()
    func makeToast(text: String)
}

class RoomMainViewModel: NSObject {
    let timeoutNumber: Double = 100
    weak var viewResponder: RoomMainViewResponder? = nil
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserModel {
        engineManager.store.currentUser
    }
    let roomRouter: RoomRouter = RoomRouter.shared
    
    override init() {
        super.init()
        fetchRoomInfo()
        getUserList(nextSequence: 0)//获取用户列表
        setLocalVideoProcessDelegate()
        subscribeEngine()
    }
    
    func applyConfigs() {
        setVideoEncoderParam()
        //如果房间不是自由发言房间并且用户没有上麦，不开启摄像头
        if roomInfo.speechMode != .freeToSpeak && !currentUser.isOnSeat {
            roomInfo.isOpenCamera = false
            roomInfo.isOpenMicrophone = false
            return
        }
        let openLocalCameraActionBlock = { [weak self] in
            guard let self = self else { return }
            let params = TRTCRenderParams()
            params.fillMode = .fill
            params.rotation = ._0
            if self.engineManager.store.videoSetting.isMirror {
                params.mirrorType = .enable
            } else {
                params.mirrorType = .disable
            }
            let roomEngine = self.engineManager.roomEngine
            roomEngine.getTRTCCloud().setLocalRenderParams(params)
            roomEngine.getTRTCCloud().setGSensorMode(.uiFixLayout)
            // FIXME: - 打开摄像头前需要先设置一个view
            roomEngine.setLocalVideoView(streamType: .cameraStream, view: nil)
            self.engineManager.openLocalCamera()
        }
        if roomInfo.isOpenCamera && !roomInfo.isCameraDisableForAllUser {
            if RoomCommon.checkAuthorCamaraStatusIsDenied() {
                openLocalCameraActionBlock()
            } else {
                RoomCommon.cameraStateActionWithPopCompletion {
                    if RoomCommon.checkAuthorCamaraStatusIsDenied() {
                        openLocalCameraActionBlock()
                    }
                }
            }
        }
    }
    
    private func setLocalVideoProcessDelegate() {
        TRTCCloud.sharedInstance().setLocalVideoProcessDelegete(self, pixelFormat: ._Texture_2D, bufferType: .texture)
    }
    
    private func deleteLocalVideoProcessDelegate() {
        TRTCCloud.sharedInstance().setLocalVideoProcessDelegete(nil, pixelFormat: ._Texture_2D, bufferType: .texture)
    }
    
    private func subscribeEngine() {
        EngineEventCenter.shared.subscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onRequestReceived, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onSendMessageForUserDisableChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserScreenCaptureStopped, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ShowBeautyView, responder: self)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onRequestReceived, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onSendMessageForUserDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserScreenCaptureStopped, observer: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ShowBeautyView, responder: self)
    }
    private func setVideoEncoderParam() {
        let param = TRTCVideoEncParam()
        param.videoResolution = engineManager.store.videoSetting.videoResolution
        param.videoBitrate = Int32(engineManager.store.videoSetting.videoBitrate)
        param.videoFps = Int32(engineManager.store.videoSetting.videoFps)
        param.resMode = .portrait
        param.enableAdjustRes = true
        engineManager.roomEngine.getTRTCCloud().setVideoEncoderParam(param)
    }
    
    private func getUserList(nextSequence: Int) {
        engineManager.roomEngine.getUserList(nextSequence: nextSequence) { [weak self] list, nextSequence in
            guard let self = self else { return }
            list.forEach { userInfo in
                self.addUserList(userInfo: userInfo)
            }
            if nextSequence != 0 {
                self.getUserList(nextSequence: nextSequence)
            }
        } onError: { code, message in
            debugPrint("getUserList:code:\(code),message:\(message)")
        }
    }
    
    private func fetchRoomInfo() {
        engineManager.roomEngine.fetchRoomInfo { [weak self] roomInfo in
            guard let self = self else { return }
            guard let roomInfo = roomInfo else { return }
            self.engineManager.store.roomInfo.update(engineRoomInfo: roomInfo)
        } onError: { code, message in
            debugPrint("")
        }
    }
    
    private func addUserList(userInfo: TUIUserInfo) {
        if let userItem = getUserItem(userInfo.userId) {
            userItem.update(userInfo: userInfo)
        } else {
            if userInfo.userId == roomInfo.ownerId {
                userInfo.userRole = .roomOwner
            }
            if userInfo.userName.isEmpty {
                userInfo.userName = userInfo.userId
            }
            let userItem = UserModel()
            userItem.update(userInfo: userInfo)
            engineManager.store.attendeeList.append(userItem)
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_RenewUserList, param: [:])
        }
    }
    
    private func getUserItem(_ userId: String) -> UserModel? {
        return engineManager.store.attendeeList.first(where: {$0.userId == userId})
    }
    
    func respondUserOnSeat(isAgree: Bool, requestId: String) {
        engineManager.roomEngine.responseRemoteRequest(requestId, agree: isAgree) { [weak self] in
            guard let self = self else { return }
            self.engineManager.store.inviteSeatMap.removeValue(forKey: self.currentUser.userId)
            self.engineManager.store.inviteSeatList = self.engineManager.store.inviteSeatList.filter { [weak self] userModel in
                guard let self = self else { return false }
                return userModel.userId == self.currentUser.userId
            }
        } onError: { code, message in
            debugPrint("responseRemoteRequest:code:\(code),message:\(message)")
        }
        if isAgree {
            currentUser.isOnSeat = true
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, param: ["isOnSeat":true])
        } else {
            currentUser.isOnSeat = false
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, param: ["isOnSeat":false])
        }
    }
    
    deinit {
        deleteLocalVideoProcessDelegate()
        unsubscribeEngine()
        debugPrint("deinit \(self)")
    }
}

extension RoomMainViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        if name == .onRoomDismissed {
            engineManager.destroyEngineManager()
            let alertVC = UIAlertController(title: .destroyAlertText, message: nil, preferredStyle: .alert)
            let sureAction = UIAlertAction(title: .alertOkText, style: .default) { [weak self] action in
                guard let self = self else { return }
                ScreenCaptureMaskView.dismiss()
                self.roomRouter.dismissAllRoomPopupViewController()
                self.roomRouter.popToRoomEntranceViewController()
            }
            alertVC.addAction(sureAction)
            roomRouter.presentAlert(alertVC)
        }
        
        if name == .onKickedOutOfRoom {
            engineManager.destroyEngineManager()
            let alertVC = UIAlertController(title: .kickOffTitleText, message: nil, preferredStyle: .alert)
            let sureAction = UIAlertAction(title: .alertOkText, style: .default) { [weak self] action in
                guard let self = self else { return }
                ScreenCaptureMaskView.dismiss()
                self.roomRouter.dismissAllRoomPopupViewController()
                self.roomRouter.popToRoomEntranceViewController()
            }
            alertVC.addAction(sureAction)
            roomRouter.presentAlert(alertVC)
        }
        
        if name == .onRequestReceived {
            guard let request = param?["request"] as? TUIRequest else { return }
            switch request.requestAction {
            case .openRemoteCamera:
                let alertVC = UIAlertController(title: .inviteTurnOnVideoText,
                                                message: "",
                                                preferredStyle: .alert)
                let declineAction = UIAlertAction(title: .declineText, style: .cancel) { [weak self] _ in
                    guard let self = self else { return }
                    self.engineManager.roomEngine.responseRemoteRequest(request.requestId, agree: false) {
                    } onError: { code, message in
                        debugPrint("openLocalCamera:code:\(code),message:\(message)")
                    }
                }
                let sureAction = UIAlertAction(title: .agreeText, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    // FIXME: - 打开摄像头前需要先设置一个view
                    self.engineManager.roomEngine.setLocalVideoView(streamType: .cameraStream, view: UIView())
                    self.engineManager.roomEngine.responseRemoteRequest(request.requestId, agree: true) {
                    } onError: { code, message in
                        debugPrint("openLocalCamera:code:\(code),message:\(message)")
                    }
                }
                alertVC.addAction(declineAction)
                alertVC.addAction(sureAction)
                roomRouter.presentAlert(alertVC)
            case .openRemoteMicrophone:
                let alertVC = UIAlertController(title: .inviteTurnOnAudioText,
                                                message: "",
                                                preferredStyle: .alert)
                let declineAction = UIAlertAction(title: .declineText, style: .cancel) { [weak self] _ in
                    guard let self = self else { return }
                    self.engineManager.roomEngine.responseRemoteRequest(request.requestId, agree: false) {
                    } onError: { code, message in
                        debugPrint("openLocalCamera:code:\(code),message:\(message)")
                    }
                }
                let sureAction = UIAlertAction(title: .agreeText, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.engineManager.roomEngine.responseRemoteRequest(request.requestId, agree: true) {
                    } onError: { code, message in
                        debugPrint("openLocalCamera:code:\(code),message:\(message)")
                    }
                }
                alertVC.addAction(declineAction)
                alertVC.addAction(sureAction)
                roomRouter.presentAlert(alertVC)
            case .invalidAction:
                break
            case .connectOtherRoom:
                engineManager.roomEngine.responseRemoteRequest(request.requestId, agree: true) {
                } onError: { _, _ in
                }
            case .remoteUserOnSeat:
                switch roomInfo.speechMode {
                case .applySpeakAfterTakingSeat:
                    let alertVC = UIAlertController(title: .inviteSpeakOnStageTitle,
                                                    message: .inviteSpeakOnStageMessage,
                                                    preferredStyle: .alert)
                    let declineAction = UIAlertAction(title: .declineText, style: .cancel) { [weak self] _ in
                        guard let self = self else { return }
                        self.respondUserOnSeat(isAgree: false, requestId: request.requestId)
                    }
                    let sureAction = UIAlertAction(title: .agreeText, style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        self.respondUserOnSeat(isAgree: true, requestId: request.requestId)
                    }
                    alertVC.addAction(declineAction)
                    alertVC.addAction(sureAction)
                    roomRouter.presentAlert(alertVC)
                default: break
                }
            default: break
            }
        }
        
        if name == .onSendMessageForUserDisableChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let muted = param?["muted"] as? Bool else { return }
            guard let userModel = engineManager.store.attendeeList.first(where: { $0.userId == userId }) else { return }
            userModel.isMuteMessage = muted
            if userId == currentUser.userId {
                currentUser.isMuteMessage = muted
                viewResponder?.makeToast(text: muted ? .messageTurnedOffText : .messageTurnedOnText)
            }
        }
        
        if name == .onUserRoleChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let userRole = param?["userRole"] as? TUIRole else { return }
            //转成房主之后需要上麦
            if userId == currentUser.userId, userRole == .roomOwner {
                viewResponder?.showSelfBecomeRoomOwnerAlert()
            }
        }
        if name == .onUserScreenCaptureStopped {
            ScreenCaptureMaskView.dismiss()
        }
    }
}

extension RoomMainViewModel: TRTCVideoFrameDelegate {
    public func onProcessVideoFrame(_ srcFrame: TRTCVideoFrame, dstFrame: TRTCVideoFrame) -> UInt32 {
        //todo：美颜组件有bug，xMagicKit初始化不成功，需要更改
        if let dstTextureId = TUICore.callService(TUICore_TUIBeautyService,
                                                  method: TUICore_TUIBeautyService_ProcessVideoFrame,
                                                  param: [
                                                    TUICore_TUIBeautyService_ProcessVideoFrame_SRCTextureIdKey: srcFrame.textureId,
                                                    TUICore_TUIBeautyService_ProcessVideoFrame_SRCFrameWidthKey: srcFrame.width,
                                                    TUICore_TUIBeautyService_ProcessVideoFrame_SRCFrameHeightKey: srcFrame.height,
                                                  ]) as? GLuint {
            dstFrame.textureId = dstTextureId
        } else {
            dstFrame.textureId = srcFrame.textureId
        }
        return 0
    }
}

extension RoomMainViewModel: RoomMainViewFactory {
    func makeBeautyView() -> UIView? {
        let beautyManager = engineManager.roomEngine.getTRTCCloud().getBeautyManager()
        let beautyInfoArray = TUICore.getExtensionList(TUICore_TUIBeautyExtension_BeautyView,
                                                       param: [
                                                        TUICore_TUIBeautyExtension_BeautyView_BeautyManager: beautyManager,])
        for extensionInfo in beautyInfoArray {
            guard let map = extensionInfo.data as? [String: Any] else { continue }
            guard let view = map[TUICore_TUIBeautyExtension_BeautyView_View] as? UIView else { continue }
            view.isHidden = true
            return view
        }
        return nil
    }
    
    func makeTopView() -> UIView {
        let viewModel = TopViewModel()
        let topView = TopView(viewModel: viewModel)
        return topView
    }
    
    func makeBottomView() -> UIView {
        let viewModel = BottomViewModel()
        let bottomView = BottomView(viewModel: viewModel)
        return bottomView
    }
    
    func makeVideoSeatView() -> UIView {
        let videoSeatView = TUIVideoSeatView(frame: UIScreen.main.bounds, roomEngine: engineManager.roomEngine,
                                             roomId: roomInfo.roomId)
        return videoSeatView
    }
    
    func makeRaiseHandNoticeView() -> UIView {
        let raiseHandNoticeView = RaiseHandNoticeView()
        //只有举手发言房间，并且用户不是房主时才会显示举手上麦提示
        if roomInfo.speechMode == .applySpeakAfterTakingSeat && currentUser.userRole != .roomOwner {
            raiseHandNoticeView.isHidden = false
        } else {
            raiseHandNoticeView.isHidden = true
        }
        return raiseHandNoticeView
    }
}

extension RoomMainViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key{
        case .TUIRoomKitService_ShowBeautyView:
            viewResponder?.showBeautyView()
        default: break
        }
    }
}

private extension String {
    static var alertOkText: String {
        localized("TUIRoom.ok")
    }
    static var kickOffTitleText: String {
        localized("TUIRoom.kick.off.title")
    }
    static var destroyAlertText: String {
        localized("TUIRoom.room.destroy")
    }
    static var inviteTurnOnAudioText: String {
        localized("TUIRoom.invite.turn.on.audio")
    }
    static var inviteTurnOnVideoText: String {
        localized("TUIRoom.invite.turn.on.video")
    }
    static var declineText: String {
        localized("TUIRoom.decline")
    }
    static var agreeText: String {
        localized("TUIRoom.agree")
    }
    static var inviteSpeakOnStageTitle: String {
        localized("TUIRoom.invite.to.speak")
    }
    static var inviteSpeakOnStageMessage: String {
        localized("TUIRoom.agree.to.speak")
    }
    static var messageTurnedOffText: String {
        localized("TUIRoom.homeowners.notice.message.turned.off")
    }
    static var messageTurnedOnText: String {
        localized("TUIRoom.homeowners.notice.message.turned.on")
    }
}
