//
//  ConferenceMainViewModel.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/27.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore
import RTCRoomEngine

protocol ConferenceMainViewResponder: AnyObject {
    func makeToast(text: String)
    func changeToolBarHiddenState()
    func setToolBarDelayHidden(isDelay: Bool)
    func showExitRoomView()
    func showAlert(title: String?, message: String?, sureTitle:String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?)
}

class ConferenceMainViewModel: NSObject {
    weak var viewResponder: ConferenceMainViewResponder? = nil
    var engineManager: EngineManager {
        EngineManager.shared
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
    var conferenceParams: ConferenceParams = ConferenceParams()
    var isShownWaterMark: Bool = FeatureSwitch.switchTextWaterMark
    
    override init() {
        super.init()
        selfRole = currentUser.userRole
        subscribeEngine()
        subLogoutNotification()
    }
    
    func applyConfigs() {
        //If the room is not a free speech room and the user is not on the microphone, the camera will not be turned on.
        if roomInfo.isSeatEnabled && !currentUser.isOnSeat {
            store.videoSetting.isCameraOpened = false
            return
        }
        let openLocalCameraActionBlock = { [weak self] in
            guard let self = self else { return }
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
        EngineEventCenter.shared.subscribeEngine(event: .onKickedOffLine, observer: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserMuteMessage, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ChangeToolBarHiddenState, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ShowExitRoomView, responder: self)
    }
    
    private func subLogoutNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(dismissConferenceViewForLogout),
                                               name: NSNotification.Name.TUILogoutSuccess, object: nil)
    }
    
    private func unsubLogoutNotification() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.TUILogoutSuccess, object: nil)
    }
    
    private func unsubscribeEngine() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onRoomDismissed, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOutOfRoom, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onRequestReceived, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onAllUserMicrophoneDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onAllUserCameraDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOffSeat, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onKickedOffLine, observer: self)
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
    
    func quickStartConference(conferenceId: String) {
        let session = ConferenceSession(conferenceId: conferenceId)
        session.conferenceParams = conferenceParams
        session.quickStart { [weak self] in
            guard let self = self else { return }
            self.store.conferenceObserver?.onConferenceStarted?(conferenceId: conferenceId, error: .success)
        } onError: { [weak self] code, message in
            guard let self = self else { return }
            let conferenceError = self.getConferenceError(error: code)
            self.store.conferenceObserver?.onConferenceStarted?(conferenceId: conferenceId, error: conferenceError)
        }
    }
    
    func joinConference(conferenceId: String) {
        let sessin = ConferenceSession(conferenceId: conferenceId)
        sessin.conferenceParams = conferenceParams
        sessin.join { [weak self] in
            guard let self = self else { return }
            self.store.conferenceObserver?.onConferenceJoined?(conferenceId: conferenceId, error: .success)
        } onError: {  [weak self] code, message in
            guard let self = self else { return }
            let conferenceError = self.getConferenceError(error: code)
            self.store.conferenceObserver?.onConferenceJoined?(conferenceId: conferenceId, error: conferenceError)
        }
    }
    
    func getConferenceError(error: TUIError) -> ConferenceError {
        guard let conferenceError = ConferenceError(rawValue: error.rawValue) else { return .failed }
        return conferenceError
    }
    
    func setConferenceParams(params: ConferenceParams) {
        conferenceParams = params
        store.setCameraOpened(params.isOpenCamera)
        store.setSoundOnSpeaker(params.isSoundOnSpeaker)
    }
    
    func setConferenceObserver(observer: ConferenceObserver?) {
        store.setConferenceObserver(observer)
    }
    
    @objc func dismissConferenceViewForLogout() {
        viewResponder?.showAlert(title: .logoutText, message: nil, sureTitle: .alertOkText, declineTitle: nil, sureBlock: {
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, param: [:])
        }, declineBlock: nil)
    }
    
    deinit {
        unsubscribeEngine()
        unsubLogoutNotification()
        debugPrint("deinit \(self)")
    }
}

extension ConferenceMainViewModel: RoomEngineEventResponder {
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
        case .onKickedOffLine:
            handleKickedOffLine()
        default: break
        }
    }
    
    private func handleRoomDismissed() {
#if RTCube_APPSTORE
        if currentUser.userRole == .roomOwner {
            let selector = NSSelectorFromString("showAlertUserLiveTimeOut")
            if UIViewController.responds(to: selector) {
                UIViewController.perform(selector)
            }
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, param: [:])
            engineManager.destroyEngineManager()
            return
        }
#endif
        engineManager.destroyEngineManager()
        viewResponder?.showAlert(title: .destroyAlertText, message: nil, sureTitle: .alertOkText, declineTitle: nil, sureBlock: {
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, param: [:])
        }, declineBlock: nil)
    }
    
    private func handleKickedOutOfRoom() {
        engineManager.destroyEngineManager()
        viewResponder?.showAlert(title: .kickOffTitleText, message: nil, sureTitle: .alertOkText, declineTitle: nil , sureBlock: {
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, param: [:])
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
        let title = localizedReplace(.inviteTurnOnVideoText, replace: nameText)
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
        let title = localizedReplace(.inviteTurnOnAudioText, replace: nameText)
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
        let title = localizedReplace(.inviteSpeakOnStageTitle, replace: nameText)
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
        engineManager.responseRemoteRequest(requestId, agree: true) {
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
        engineManager.responseRemoteRequest(requestId, agree: false) {
        } onError: { code, message in
            debugPrint("responseRemoteRequest:code:\(code),message:\(message)")
        }
    }
    
    private func handleKickedOffLine() {
        viewResponder?.showAlert(title: .kieckedOffLineText, message: nil, sureTitle: .alertOkText, declineTitle: nil, sureBlock: {
            EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_DismissConferenceViewController, param: [:])
        }, declineBlock: nil)
    }
}

extension ConferenceMainViewModel: ConferenceMainViewFactory {
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
        let viewModel = TUIVideoSeatViewModel()
        let videoSeatView = TUIVideoSeatView(viewModel: viewModel)
        videoSeatView.backgroundColor = UIColor(0x0F1014)
        return videoSeatView
    }
    
    func makeRaiseHandNoticeView() -> UIView {
        let raiseHandNoticeView = RaiseHandNoticeView()
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
    
    func makeWaterMarkLayer() -> WaterMarkLayer {
        let layer = WaterMarkLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.anchorPoint = CGPointZero
        layer.text = currentUser.userId + "(" + currentUser.userName + ")"
        layer.lineStyle = .multiLine
        layer.cornerRadius = 16
        return layer
    }
    
    func makeFloatChatButton() -> FloatChatButton {
        let floatchatButton = FloatChatButton(roomId: store.roomInfo.roomId)
        floatchatButton.isHidden = !store.shouldShowFloatChatView
        return floatchatButton
    }
    
    func makeFloatChatDisplayView() -> FloatChatDisplayView {
        let view = FloatChatDisplayView()
        view.isHidden = !store.shouldShowFloatChatView
        return view
    }
    
    func makeRaiseHandApplicationNotificationView() -> RaiseHandApplicationNotificationView {
        let viewModel = RaiseHandApplicationNotificationViewModel()
        let notificationView = RaiseHandApplicationNotificationView(viewModel: viewModel)
        return notificationView
    }
}

extension ConferenceMainViewModel: RoomKitUIEventResponder {
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
        localized("You were removed by the host.")
    }
    static var destroyAlertText: String {
        localized("The conference was closed.")
    }
    static var inviteTurnOnAudioText: String {
        localized("xx invites you to turn on the microphone")
    }
    static var inviteTurnOnVideoText: String {
        localized("xx invites you to turn on the camera")
    }
    static var inviteSpeakOnStageTitle: String {
        localized("xx invites you to speak on stage")
    }
    static var inviteSpeakOnStageMessage: String {
        localized("You can turn on the camera and unmute it once you are on stage")
    }
    static var messageTurnedOffText: String {
        localized("You were muted message by the host.")
    }
    static var messageTurnedOnText: String {
        localized("You were unmuted message by the host.")
    }
    static var haveBecomeMasterText: String {
        localized("You are now a host")
    }
    static var haveBecomeAdministratorText: String {
        localized("You have become a conference admin")
    }
    static var kickedOffLineText: String {
        localized("You are already logged in elsewhere")
    }
    static var alertOkText: String {
        localized("OK")
    }
    static var declineText: String {
        localized("Decline")
    }
    static var agreeText: String {
        localized("Agree")
    }
    static var agreeSeatText: String {
        localized("Approve")
    }
    static var allMuteAudioText: String {
        localized("All audios disabled")
    }
    static var allMuteVideoText: String {
        localized("All videos disabled")
    }
    static var allUnMuteAudioText: String {
        localized("All audios enabled")
    }
    static var allUnMuteVideoText: String {
        localized("All videos enabled")
    }
    static var kickedOffSeat: String {
        localized("You have been asked to leave stage")
    }
    static var hostText: String {
        localized("Host")
    }
    static var administratorText: String {
        localized("Administrator")
    }
    static var revokedAdministratorText: String {
        localized("Your conference admin status has been revoked")
    }
    static var onStageNumberReachedLimitText: String {
        localized("The stage is full, please contact the host")
    }
    static var goOnStageTimedOutText: String {
        localized("Failed to go on stage, invitation has timed out")
    }
    static var kieckedOffLineText: String {
        localized("You are already logged in elsewhere")
    }
    static var logoutText: String {
        localized("You are logged out")
    }
}
