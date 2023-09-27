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
    func makeToast(text: String)
    func changeToolBarHiddenState()
    func setToolBarDelayHidden(isDelay: Bool)
}

class RoomMainViewModel: NSObject {
    weak var viewResponder: RoomMainViewResponder? = nil
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var store: RoomStore {
        engineManager.store
    }
    var roomInfo: TUIRoomInfo {
        store.roomInfo
    }
    var currentUser: UserEntity {
        store.currentUser
    }
    let roomRouter: RoomRouter = RoomRouter.shared
    
    override init() {
        super.init()
        subscribeEngine()
    }
    
    func applyConfigs() {
        setVideoEncoderParam()
        //如果房间不是自由发言房间并且用户没有上麦，不开启摄像头
        if roomInfo.speechMode != .freeToSpeak && !currentUser.isOnSeat {
            store.videoSetting.isCameraOpened = false
            return
        }
        let openLocalCameraActionBlock = { [weak self] in
            guard let self = self else { return }
            let params = TRTCRenderParams()
            params.fillMode = .fill
            params.rotation = ._0
            self.engineManager.setLocalRenderParams(params: params)
            self.engineManager.setGSensorMode(mode: .uiFixLayout)
            // FIXME: - 打开摄像头前需要先设置一个view
            self.engineManager.setLocalVideoView(streamType: .cameraStream, view: nil)
            self.engineManager.openLocalCamera()
        }
        if store.videoSetting.isCameraOpened && !roomInfo.isCameraDisableForAllUser {
            if RoomCommon.checkAuthorCamaraStatusIsDenied() {
                openLocalCameraActionBlock()
            } else {
                RoomCommon.cameraStateActionWithPopCompletion { granted in
                    if granted {
                        openLocalCameraActionBlock()
                    }
                }
            }
        }
    }
    
    private func subscribeEngine() {
        EngineEventCenter.shared.subscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onRequestReceived, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserMuteMessage, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ChangeToolBarHiddenState, responder: self)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onRequestReceived, observer: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserMuteMessage, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ChangeToolBarHiddenState, responder: self)
    }
    private func setVideoEncoderParam() {
        let param = TRTCVideoEncParam()
        param.videoResolution = engineManager.store.videoSetting.videoResolution
        param.videoBitrate = Int32(engineManager.store.videoSetting.videoBitrate)
        param.videoFps = Int32(engineManager.store.videoSetting.videoFps)
        param.resMode = .portrait
        param.enableAdjustRes = true
        engineManager.setVideoEncoderParam(param)
    }
    func respondUserOnSeat(isAgree: Bool, requestId: String) {
        engineManager.responseRemoteRequest(requestId, agree: isAgree) { [weak self] in
            guard let self = self else { return }
            self.engineManager.deleteInviteSeatUser(self.currentUser.userId)
        } onError: { code, message in
            debugPrint("responseRemoteRequest:code:\(code),message:\(message)")
        }
    }
    
    deinit {
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
                    self.engineManager.responseRemoteRequest(request.requestId, agree: false)
                }
                let sureAction = UIAlertAction(title: .agreeText, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    // FIXME: - 打开摄像头前需要先设置一个view
                    self.engineManager.setLocalVideoView(streamType: .cameraStream, view: nil)
                    // 需要先判断是否有摄像头权限
                    if RoomCommon.checkAuthorCamaraStatusIsDenied() {
                        self.engineManager.responseRemoteRequest(request.requestId, agree: true)
                    } else {
                        //如果没有摄像头权限，需要先去打开摄像头权限
                        RoomCommon.cameraStateActionWithPopCompletion { [weak self] granted in
                            guard let self = self else { return }
                            self.engineManager.responseRemoteRequest(request.requestId, agree: granted)
                        }
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
                    self.engineManager.responseRemoteRequest(request.requestId, agree: false)
                }
                let sureAction = UIAlertAction(title: .agreeText, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    if RoomCommon.checkAuthorMicStatusIsDenied() {
                        self.engineManager.responseRemoteRequest(request.requestId, agree: true)
                    } else {
                        RoomCommon.micStateActionWithPopCompletion { [weak self] granted in
                            guard let self = self else { return }
                            self.engineManager.responseRemoteRequest(request.requestId, agree: granted)
                        }
                    }
                }
                alertVC.addAction(declineAction)
                alertVC.addAction(sureAction)
                roomRouter.presentAlert(alertVC)
            case .invalidAction:
                break
            case .connectOtherRoom:
                engineManager.responseRemoteRequest(request.requestId, agree: true)
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
    }
}

extension RoomMainViewModel: RoomMainViewFactory {
    func makeTopView() -> TopView {
        let viewModel = TopViewModel()
        let topView = TopView(viewModel: viewModel)
        topView.backgroundColor = UIColor(0x0F1014)
        return topView
    }
    
    func makeBottomView() -> BottomView {
        let viewModel = BottomViewModel()
        let bottomView = BottomView(viewModel: viewModel)
        return bottomView
    }
    
    func makeVideoSeatView() -> UIView {
        let videoSeatView = TUIVideoSeatView(frame: UIScreen.main.bounds, roomEngine: engineManager.roomEngine,
                                             roomId: roomInfo.roomId)
        videoSeatView.backgroundColor = UIColor(0x0F1014)
        return videoSeatView
    }
    
    func makeRaiseHandNoticeView() -> UIView {
        let raiseHandNoticeView = RaiseHandNoticeView()
        //只有举手发言房间，并且用户不是房主时才会显示举手上麦提示
        if roomInfo.speechMode == .applySpeakAfterTakingSeat && currentUser.userId != roomInfo.ownerId {
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
        case .TUIRoomKitService_CurrentUserRoleChanged:
            guard let userRole = info?["userRole"] as? TUIRole else { return }
            guard userRole == .roomOwner else { return }
            viewResponder?.showSelfBecomeRoomOwnerAlert()
        case .TUIRoomKitService_CurrentUserMuteMessage:
            guard let isMute = info?["isMute"] as? Bool else { return }
            viewResponder?.makeToast(text: isMute ? .messageTurnedOffText : .messageTurnedOnText)
        case .TUIRoomKitService_ChangeToolBarHiddenState:
            viewResponder?.changeToolBarHiddenState()
        case .TUIRoomKitService_SetToolBarDelayHidden:
            guard let isDelay = info?["isDelay"] as? Bool else { return }
            viewResponder?.setToolBarDelayHidden(isDelay: isDelay)
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
