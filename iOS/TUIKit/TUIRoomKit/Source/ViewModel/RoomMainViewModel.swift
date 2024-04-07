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
    func makeToast(text: String)
    func changeToolBarHiddenState()
    func setToolBarDelayHidden(isDelay: Bool)
    func showExitRoomView()
    func showAlert(title: String?, message: String?, sureTitle:String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?)
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
    private var isShownOpenCameraInviteAlert = false
    private var isShownOpenMicrophoneInviteAlert = false
    private var isShownTakeSeatInviteAlert = false
    private weak var localAudioViewModel: LocalAudioViewModel?
    private var selfRole: TUIRole?
    
    override init() {
        super.init()
        selfRole = currentUser.userRole
        subscribeEngine()
    }
    
    func applyConfigs() {
        //如果房间不是自由发言房间并且用户没有上麦，不开启摄像头
        if roomInfo.isSeatEnabled && !currentUser.isOnSeat {
            store.videoSetting.isCameraOpened = false
            return
        }
        let openLocalCameraActionBlock = { [weak self] in
            guard let self = self else { return }
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
        EngineEventCenter.shared.subscribeEngine(event: .onAllUserMicrophoneDisableChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onAllUserCameraDisableChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onKickedOffSeat, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserMuteMessage, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ChangeToolBarHiddenState, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ShowExitRoomView, responder: self)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onRequestReceived, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onAllUserMicrophoneDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onAllUserCameraDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOffSeat, observer: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserMuteMessage, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ChangeToolBarHiddenState, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ShowExitRoomView, responder: self)
    }
    
    func hideLocalAudioView() {
        localAudioViewModel?.hideLocalAudioView()
    }
    
    func showLocalAudioView() {
        localAudioViewModel?.showLocalAudioView()
    }
    
    deinit {
        unsubscribeEngine()
        debugPrint("deinit \(self)")
    }
}

extension RoomMainViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onRoomDismissed:
            handleRoomDismissed()
        case .onKickedOutOfRoom:
            handleKickedOutOfRoom()
        case .onAllUserMicrophoneDisableChanged:
            guard let isDisable = param?["isDisable"] as? Bool else { return }
            handleAllUserMicrophoneDisableChanged(isDisable: isDisable)
        case .onAllUserCameraDisableChanged:
            guard let isDisable = param?["isDisable"] as? Bool else { return }
            handleAllUserCameraDisableChanged(isDisable: isDisable)
        case .onKickedOffSeat:
            viewResponder?.makeToast(text: .kickedOffSeat)
        case .onRequestReceived:
            guard let request = param?["request"] as? TUIRequest else { return }
            handleReceivedRequest(request: request)
        default: break
        }
    }
    
    private func handleRoomDismissed() {
        engineManager.destroyEngineManager()
        viewResponder?.showAlert(title: .destroyAlertText, message: nil, sureTitle: .alertOkText, declineTitle: nil, sureBlock: { [weak self] in
            guard let self = self else { return }
            self.roomRouter.dismissAllRoomPopupViewController()
            self.roomRouter.popToRoomEntranceViewController()
        }, declineBlock: nil)
    }
    
    private func handleKickedOutOfRoom() {
        engineManager.destroyEngineManager()
        viewResponder?.showAlert(title: .kickOffTitleText, message: nil, sureTitle: .alertOkText, declineTitle: nil , sureBlock: { [weak self] in
            guard let self = self else { return }
            self.roomRouter.dismissAllRoomPopupViewController()
            self.roomRouter.popToRoomEntranceViewController()
        }, declineBlock: nil)
    }
    
    private func handleAllUserMicrophoneDisableChanged(isDisable: Bool) {
        if isDisable {
            RoomRouter.makeToastInCenter(toast: .allMuteAudioText, duration: 1.5)
        } else {
            RoomRouter.makeToastInCenter(toast: .allUnMuteAudioText, duration: 1.5)
        }
    }
    
    private func handleAllUserCameraDisableChanged(isDisable: Bool) {
        if isDisable {
            RoomRouter.makeToastInCenter(toast: .allMuteVideoText, duration: 1.5)
        } else {
            RoomRouter.makeToastInCenter(toast: .allUnMuteVideoText, duration: 1.5)
        }
    }
    
    private func handleReceivedRequest(request: TUIRequest) {
        switch request.requestAction {
        case .openRemoteCamera:
            handleOpenCameraRequest(request: request)
        case .openRemoteMicrophone:
            handleOpenMicrophoneRequest(request: request)
        case .invalidAction:
            break
        case .connectOtherRoom:
            engineManager.responseRemoteRequest(request.requestId, agree: true)
        case .remoteUserOnSeat:
            handleOnSeatRequest(request: request)
        default: break
        }
    }
    
    private func handleOpenCameraRequest(request: TUIRequest) {
        guard !isShownOpenCameraInviteAlert else { return }
        guard let userInfo = store.attendeeList.first(where: { $0.userId == request.userId }) else { return }
        let nameText: String = userInfo.userRole == .roomOwner ? .hostText : .administratorText
        let title = nameText + .inviteTurnOnVideoText
        viewResponder?.showAlert(title: title, message: nil, sureTitle: .agreeText, declineTitle: .declineText, sureBlock: { [weak self] in
            guard let self = self else { return }
            self.isShownOpenCameraInviteAlert = false
            self.agreeOpenLocalCamera(request: request)
        }, declineBlock: { [weak self] in
            guard let self = self else { return }
            self.isShownOpenCameraInviteAlert = false
            self.engineManager.responseRemoteRequest(request.requestId, agree: false)
        })
        isShownOpenCameraInviteAlert = true
    }
    
    private func agreeOpenLocalCamera(request: TUIRequest) {
        engineManager.setLocalVideoView(streamType: .cameraStream, view: nil)
        if RoomCommon.checkAuthorCamaraStatusIsDenied() {
            engineManager.responseRemoteRequest(request.requestId, agree: true)
        } else {
            RoomCommon.cameraStateActionWithPopCompletion { [weak self] granted in
                guard let self = self else { return }
                self.engineManager.responseRemoteRequest(request.requestId, agree: granted)
            }
        }
    }
    
    private func handleOpenMicrophoneRequest(request: TUIRequest) {
        guard !isShownOpenMicrophoneInviteAlert else { return }
        guard let userInfo = store.attendeeList.first(where: { $0.userId == request.userId }) else { return }
        let nameText: String = userInfo.userRole == .roomOwner ? .hostText : .administratorText
        let title = nameText + .inviteTurnOnAudioText
        viewResponder?.showAlert(title: title, message: nil, sureTitle: .agreeText, declineTitle: .declineText, sureBlock: { [weak self] in
            guard let self = self else { return }
            self.isShownOpenMicrophoneInviteAlert = false
            self.agreeOpenLocalMic(request: request)
        }, declineBlock: { [weak self] in
            guard let self = self else { return }
            self.isShownOpenMicrophoneInviteAlert = false
            self.engineManager.responseRemoteRequest(request.requestId, agree: false)
        })
        isShownOpenMicrophoneInviteAlert = true
    }
    
    private func agreeOpenLocalMic(request: TUIRequest) {
        if RoomCommon.checkAuthorMicStatusIsDenied() {
            self.engineManager.responseRemoteRequest(request.requestId, agree: true)
        } else {
            RoomCommon.micStateActionWithPopCompletion { [weak self] granted in
                guard let self = self else { return }
                self.engineManager.responseRemoteRequest(request.requestId, agree: granted)
            }
        }
    }
    
    private func handleOnSeatRequest(request: TUIRequest) {
        guard roomInfo.isSeatEnabled && !isShownTakeSeatInviteAlert else { return }
        guard let userInfo = store.attendeeList.first(where: { $0.userId == request.userId }) else { return }
        let nameText: String = userInfo.userRole == .roomOwner ? .hostText : .administratorText
        let title = nameText + .inviteSpeakOnStageTitle
        viewResponder?.showAlert(title: title, message: .inviteSpeakOnStageMessage, sureTitle: .agreeSeatText, declineTitle: .declineText, sureBlock: { [weak self] in
            guard let self = self else { return }
            self.isShownTakeSeatInviteAlert = false
            self.agreeOnSeatRequest(requestId: request.requestId)
        }, declineBlock: { [weak self] in
            guard let self = self else { return }
            self.isShownTakeSeatInviteAlert = false
            self.disagreeOnSeatRequest(requestId: request.requestId)
        })
        isShownTakeSeatInviteAlert = true
    }
    
    private func agreeOnSeatRequest(requestId: String) {
        engineManager.responseRemoteRequest(requestId, agree: true) { [weak self] in
            guard let self = self else { return }
            self.engineManager.deleteInviteSeatUser(self.currentUser.userId)
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            switch code {
            case .failed:
                self.viewResponder?.makeToast(text: .goOnStageTimedOutText)
            case .allSeatOccupied:
                self.viewResponder?.makeToast(text: .onStageNumberReachedLimitText)
            default: break
            }
        }
    }
    
    private func disagreeOnSeatRequest(requestId: String) {
        engineManager.responseRemoteRequest(requestId, agree: false) { [weak self] in
            guard let self = self else { return }
            self.engineManager.deleteInviteSeatUser(self.currentUser.userId)
        } onError: { code, message in
            debugPrint("responseRemoteRequest:code:\(code),message:\(message)")
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
        let videoSeatView = TUIVideoSeatView()
        videoSeatView.backgroundColor = UIColor(0x0F1014)
        return videoSeatView
    }
    
    func makeRaiseHandNoticeView() -> UIView {
        let raiseHandNoticeView = RaiseHandNoticeView()
        //只有举手发言房间，并且用户不是房主时才会显示举手上麦提示
        if roomInfo.isSeatEnabled, currentUser.userId != roomInfo.ownerId, store.isShownRaiseHandNotice {
            raiseHandNoticeView.isHidden = false
        } else {
            raiseHandNoticeView.isHidden = true
        }
        return raiseHandNoticeView
    }
    
    func makeLocalAudioView() -> UIView {
        let localAudioViewModel  = LocalAudioViewModel()
        localAudioViewModel.hideLocalAudioView()
        let view = LocalAudioView(viewModel: localAudioViewModel)
        self.localAudioViewModel = localAudioViewModel
        return view
    }
}

extension RoomMainViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key{
        case .TUIRoomKitService_CurrentUserRoleChanged:
            guard let userRole = info?["userRole"] as? TUIRole else { return }
            handleSelfRoleChanged(userRole: userRole)
        case .TUIRoomKitService_CurrentUserMuteMessage:
            guard let isMute = info?["isMute"] as? Bool else { return }
            viewResponder?.makeToast(text: isMute ? .messageTurnedOffText : .messageTurnedOnText)
        case .TUIRoomKitService_ChangeToolBarHiddenState:
            viewResponder?.changeToolBarHiddenState()
        case .TUIRoomKitService_SetToolBarDelayHidden:
            guard let isDelay = info?["isDelay"] as? Bool else { return }
            viewResponder?.setToolBarDelayHidden(isDelay: isDelay)
        case .TUIRoomKitService_ShowExitRoomView:
            viewResponder?.showExitRoomView()
        default: break
        }
    }
    
    private func handleSelfRoleChanged(userRole: TUIRole) {
        switch userRole {
        case .roomOwner:
            viewResponder?.makeToast(text: .haveBecomeMasterText)
        case .administrator:
            viewResponder?.makeToast(text: .haveBecomeAdministratorText)
        case .generalUser:
            if selfRole == .administrator {
                viewResponder?.makeToast(text: .revokedAdministratorText)
            }
        default: break
        }
        selfRole = userRole
    }
}

private extension String {
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
    static var haveBecomeMasterText: String {
        localized("TUIRoom.have.become.master")
    }
    static var haveBecomeAdministratorText: String {
        localized("TUIRoom.have.become.administrator")
    }
    static var kickedOffLineText: String {
        localized("TUIRoom.kicked.off.line")
    }
    static var alertOkText: String {
        localized("TUIRoom.ok")
    }
    static var declineText: String {
        localized("TUIRoom.decline")
    }
    static var agreeText: String {
        localized("TUIRoom.agree")
    }
    static var agreeSeatText: String {
        localized("TUIRoom.agree.seat")
    }
    static var allMuteAudioText: String {
        localized("TUIRoom.all.mute.audio.prompt")
    }
    static var allMuteVideoText: String {
        localized("TUIRoom.all.mute.video.prompt")
    }
    static var allUnMuteAudioText: String {
        localized("TUIRoom.all.unmute.audio.prompt")
    }
    static var allUnMuteVideoText: String {
        localized("TUIRoom.all.unmute.video.prompt")
    }
    static var kickedOffSeat: String {
        localized("TUIRoom.kicked.off.seat")
    }
    static var hostText: String {
        localized("TUIRoom.host")
    }
    static var administratorText: String {
        localized("TUIRoom.role.administrator")
    }
    static var revokedAdministratorText: String {
        localized("TUIRoom.revoked.your.administrator")
    }
    static var onStageNumberReachedLimitText: String {
        localized("TUIRoom.on.stage.number.reached.limit")
    }
    static var goOnStageTimedOutText: String {
        localized("TUIRoom.go.on.stage.timed.out")
    }
}
