//
//  BottomViewModel.swift
//  Alamofire
//
//  Created by aby on 2022/12/22.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine
import TUICore

protocol BottomViewModelResponder: AnyObject {
    func updateButtonView(item: ButtonItemData)
    func makeToast(text: String)
    func updataBottomView(isUp:Bool)
    func updateStackView(items: [ButtonItemData])
    func showAlert(title: String?, message: String?, sureTitle:String?, declineTitle: String?, sureBlock: (() -> ())?, declineBlock: (() -> ())?)
}

class BottomViewModel: NSObject {
    private(set) var viewItems: [ButtonItemData] = []
    weak var viewResponder: BottomViewModelResponder?
    
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var engineEventCenter: EngineEventCenter {
        EngineEventCenter.shared
    }
    var roomInfo: TUIRoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserEntity {
        engineManager.store.currentUser
    }
    var attendeeList: [UserEntity] {
        engineManager.store.attendeeList
    }
    var inviteSeatList: [RequestEntity] {
        engineManager.store.inviteSeatList
    }
    var isCalledFromShareScreen = false
    
    private lazy var memberItem: ButtonItemData = {
        let memberItem = ButtonItemData()
        memberItem.normalTitle = String(format: .memberText, attendeeList.count)
        memberItem.normalIcon = "room_member"
        memberItem.resourceBundle = tuiRoomKitBundle()
        memberItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.memberAction(sender: button)
        }
        return memberItem
    }()
    private lazy var muteAudioItem: ButtonItemData = {
        let muteAudioItem = ButtonItemData()
        muteAudioItem.normalTitle = .muteAudioText
        muteAudioItem.selectedTitle = .unMuteAudioText
        muteAudioItem.normalIcon = "room_unMute_audio"
        muteAudioItem.selectedIcon = "room_mic_off"
        muteAudioItem.resourceBundle = tuiRoomKitBundle()
        muteAudioItem.buttonType = .muteAudioItemType
        muteAudioItem.isSelect = !currentUser.hasAudioStream
        muteAudioItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteAudioAction(sender: button)
        }
        return muteAudioItem
    }()
    private lazy var muteVideoItem: ButtonItemData = {
        let muteVideoItem = ButtonItemData()
        muteVideoItem.normalTitle = .muteVideoText
        muteVideoItem.selectedTitle = .unMuteVideoText
        muteVideoItem.normalIcon = "room_camera_on"
        muteVideoItem.selectedIcon = "room_camera_off"
        muteVideoItem.resourceBundle = tuiRoomKitBundle()
        muteVideoItem.buttonType = .muteVideoItemType
        muteVideoItem.isSelect = !currentUser.hasVideoStream
        muteVideoItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteVideoAction(sender: button)
        }
        return muteVideoItem
    }()
    private lazy var shareScreenItem: ButtonItemData = {
        let shareScreenItem = ButtonItemData()
        shareScreenItem.normalTitle = .shareScreenOnText
        shareScreenItem.selectedTitle = .shareScreenOffText
        shareScreenItem.normalIcon = "room_shareScreen_on"
        shareScreenItem.selectedIcon = "room_shareScreen_off"
        shareScreenItem.resourceBundle = tuiRoomKitBundle()
        shareScreenItem.buttonType = .shareScreenItemType
        shareScreenItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.shareScreenAction(sender: button)
        }
        return shareScreenItem
    }()
    private lazy var chatItem: ButtonItemData = {
        let chatItem = ButtonItemData()
        chatItem.normalIcon = "room_chat"
        chatItem.normalTitle = .chatText
        chatItem.resourceBundle = tuiRoomKitBundle()
        chatItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.chatAction(sender: button)
        }
        return chatItem
    }()
    private lazy var moreItem: ButtonItemData = {
        let moreItem = ButtonItemData()
        moreItem.normalTitle = .unfoldText
        moreItem.normalIcon = "room_more"
        moreItem.selectedTitle = .dropText
        moreItem.selectedIcon = "room_drop"
        moreItem.resourceBundle = tuiRoomKitBundle()
        moreItem.buttonType = .moreItemType
        moreItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.moreAction(sender: button)
        }
        return moreItem
    }()
    
    private lazy var floatItem: ButtonItemData = {
        let floatItem = ButtonItemData()
        floatItem.normalTitle = .floatText
        floatItem.normalIcon = "room_float"
        floatItem.resourceBundle = tuiRoomKitBundle()
        floatItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.floatAction(sender: button)
        }
        return floatItem
    }()
    private lazy var setupItem: ButtonItemData = {
        let setupItem = ButtonItemData()
        setupItem.normalTitle = .setupText
        setupItem.normalIcon = "room_setting"
        setupItem.resourceBundle = tuiRoomKitBundle()
        setupItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.setupAction(sender: button)
        }
        return setupItem
    }()
    private lazy var inviteItem: ButtonItemData = {
        let inviteItem = ButtonItemData()
        inviteItem.normalTitle = .inviteText
        inviteItem.normalIcon = "room_invite"
        inviteItem.resourceBundle = tuiRoomKitBundle()
        inviteItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.inviteAction(sender: button)
        }
        return inviteItem
    }()
    
    private lazy var raiseHandApplyItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = .stageManagementText
        item.normalIcon = "room_hand_raise_list"
        item.resourceBundle = tuiRoomKitBundle()
        item.buttonType = .raiseHandApplyItemType
        item.noticeText = String(inviteSeatList.count)
        item.hasNotice = inviteSeatList.count > 0
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.raiseHandApplyAction(sender: button)
        }
        return item
    }()
    
    private lazy var raiseHandItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalTitle = currentUser.userRole == .generalUser ? .applyJoinStageText : .joinStageText
        item.normalIcon = "room_apply_join_stage"
        item.selectedIcon = "room_cancel_request"
        item.selectedTitle = .cancelStageText
        item.resourceBundle = tuiRoomKitBundle()
        item.buttonType = .raiseHandItemType
        item.isSelect = engineManager.store.selfTakeSeatRequestId != nil
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.raiseHandAction(sender: button)
        }
        return item
    }()
    
    private lazy var leaveSeatHandItem: ButtonItemData = {
        let item = ButtonItemData()
        item.normalIcon = "room_leave_seat"
        item.selectedIcon = "room_apply_join_stage"
        item.normalTitle = .leaveSeatText
        item.selectedTitle = .applyJoinStageText
        item.buttonType = .leaveSeatItemType
        item.resourceBundle = tuiRoomKitBundle()
        item.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.leaveSeatAction(sender: button)
        }
        return item
    }()
    
    override init() {
        super.init()
        createBottomData()
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserHasAudioStream, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_CurrentUserHasVideoStream, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_SomeoneSharing, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        EngineEventCenter.shared.subscribeEngine(event: .onAllUserCameraDisableChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onAllUserMicrophoneDisableChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onInitialSelfUserInfo, observer: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onUserScreenCaptureStarted),
                                               name: UIScreen.capturedDidChangeNotification, object: nil)
    }
    
    func createBottomData() {
        creatBaseBottomData()
        createMoreBottomData()
    }
    
    func creatBaseBottomData(){
        viewItems.append(memberItem)
        viewItems.append(muteAudioItem)
        viewItems.append(muteVideoItem)
        if roomInfo.isSeatEnabled {
            if currentUser.userRole == .roomOwner {
                viewItems.append(raiseHandApplyItem)
            } else {
                if currentUser.isOnSeat {
                    viewItems.append(leaveSeatHandItem)
                } else {
                    viewItems.append(raiseHandItem)
                }
            }
            if currentUser.userRole == .administrator {
                viewItems.append(raiseHandApplyItem)
            }
        }
        viewItems.append(shareScreenItem)
        if hasTUIChatItem() {
            viewItems.append(chatItem)
        }
        viewItems.append(moreItem)
        updateAudioItem()
        updateVideoItem()
    }
    
    func createMoreBottomData(){
        viewItems.append(inviteItem)
        viewItems.append(floatItem)
        viewItems.append(setupItem)
        reorderTheMoreItem()
    }
    
    func memberAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .userListViewType, height: 720.scale375Height(), backgroundColor: UIColor(0x17181F))
    }
    
    func muteAudioAction(sender: UIButton) {
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        if currentUser.hasAudioStream {
            engineManager.muteLocalAudio()
            return
        }
        //If all hosts are muted, ordinary members of the room cannot turn on their microphones.
        if self.roomInfo.isMicrophoneDisableForAllUser && currentUser.userRole == .generalUser {
            viewResponder?.makeToast(text: .muteAudioRoomReasonText)
            return
        }
        //If you are speaking in a room with your hand raised and you are not on the microphone, you cannot turn on the microphone.
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteSeatReasonText)
            return
        }
        engineManager.unmuteLocalAudio()
        guard !engineManager.store.audioSetting.isMicOpened else { return }
        engineManager.openLocalMicrophone()
    }
    
    func muteVideoAction(sender: UIButton) {
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        if currentUser.hasVideoStream {
            engineManager.closeLocalCamera()
            return
        }
        //If the entire host bans paintings, ordinary members of the room cannot turn on the camera.
        if self.roomInfo.isCameraDisableForAllUser && self.currentUser.userRole == .generalUser {
            viewResponder?.makeToast(text: .muteVideoRoomReasonText)
            return
        }
        //If you are speaking in a room with your hands raised and you are not on the mic, you cannot turn on the camera.
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteSeatReasonText)
            return
        }
        engineManager.setLocalVideoView(streamType: .cameraStream, view: nil)
        engineManager.openLocalCamera()
    }
    
    func raiseHandApplyAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .raiseHandApplicationListViewType, height: 720.scale375Height(), backgroundColor: UIColor(0x22262E))
    }
    
    func raiseHandAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        if sender.isSelected {
            handleRaiseHandAction()
        } else {
            handleCancelRaiseHandAction()
        }
    }
    
    func handleRaiseHandAction() {
        _ = engineManager.takeSeat() { [weak self] _,_ in
            guard let self = self else { return }
            self.viewResponder?.makeToast(text: .takenSeatText)
        } onRejected: { [weak self] _, _, _ in
            guard let self = self else { return }
            self.viewResponder?.makeToast(text: .rejectedTakeSeatText)
            self.changeItemSelectState(type: .raiseHandItemType, isSelected: false)
        } onTimeout: { [weak self] requestId, userId in
            guard let self = self else { return }
            self.viewResponder?.makeToast(text: .joinStageApplicationTimedOutText)
            self.changeItemSelectState(type: .raiseHandItemType, isSelected: false)
        } onError: { [weak self] _, _, code, message in
            guard let self = self else { return }
            self.changeItemSelectState(type: .raiseHandItemType, isSelected: false)
        }
        changeItemSelectState(type: .raiseHandItemType)
        guard currentUser.userRole == .generalUser else { return }
        viewResponder?.makeToast(text: .applicationHasSentText)
    }
    
    func handleCancelRaiseHandAction() {
        engineManager.cancelTakeSeatRequest()
        changeItemSelectState(type: .raiseHandItemType)
        viewResponder?.makeToast(text: .joinStageApplicationCancelledText)
    }
    
    func leaveSeatAction(sender: UIButton) {
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        if currentUser.userRole == .administrator {
            engineManager.leaveSeat()
        } else {
            viewResponder?.showAlert(title: .leaveSeatTitle, message: .leaveSeatMessage, sureTitle: .leaveSeatText, declineTitle: .toastCancelText, sureBlock: { [weak self] in
                guard let self = self else { return }
                self.engineManager.leaveSeat()
            }, declineBlock: nil)
        }
    }
    
    func shareScreenAction(sender: UIButton) {
        if #available(iOS 12.0, *) {
            guard let item = viewItems.first(where: { $0.buttonType == .shareScreenItemType })
            else { return }
            if !item.isSelect {
                //If someone else is screen sharing, you can no longer screen share yourself
                guard engineManager.store.attendeeList.first(where: {$0.hasScreenStream}) == nil else {
                    viewResponder?.makeToast(text: .othersScreenSharingText)
                    return
                }
                //If you are in a room where you are raising your hand to speak, and you are not on the mic, you cannot share your screen.
                guard !(roomInfo.isSeatEnabled && !currentUser.isOnSeat) else {
                    viewResponder?.makeToast(text: .muteSeatReasonText)
                    return
                }
                if TUICore.callService(TUICore_PrivacyService,
                                       method: TUICore_PrivacyService_ScreenShareAntifraudReminderMethod,
                                       param: nil, resultCallback: { [weak self] code, message, param in
                    guard let self = self else { return }
                    if code == TUICore_PrivacyService_EnableScreenShareAntifraudReminderMethod_Continue {
                        self.isCalledFromShareScreen = true
                        BroadcastLauncher.launch()
                    }
                }) == nil {
                    isCalledFromShareScreen = true
                    BroadcastLauncher.launch()
                }
            } else {
                viewResponder?.showAlert(title: .toastTitleText, message: .toastMessageText, sureTitle: .toastStopText, declineTitle: .toastCancelText, sureBlock: { [weak self] in
                    guard let self = self else { return }
                    self.engineManager.stopScreenCapture()
                }, declineBlock: nil)
            }
        } else {
            viewResponder?.makeToast(text: .versionLowToastText)
        }
    }
    
    func chatAction(sender: UIButton) {
        let user = engineManager.store.currentUser
        let roomInfo = engineManager.store.roomInfo
        RoomRouter.shared.pushToChatController(user: user, roomInfo: roomInfo)
    }
    
    func moreAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": !sender.isSelected])
        viewResponder?.updataBottomView(isUp: sender.isSelected)
        changeItemSelectState(type: .moreItemType)
    }
    
    func inviteAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .inviteViewType, height: 186)
    }
    
    func floatAction(sender: UIButton) {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ShowRoomVideoFloatView, param: [:])
    }
    
    func setupAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .mediaSettingViewType, height: 709.scale375Height())
    }
    
    @objc func onUserScreenCaptureStarted(notification:Notification)
    {
        guard let screen = notification.object as? UIScreen else {return}
        if screen.isCaptured,isCalledFromShareScreen {
            engineManager.startScreenCapture()
        }
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserRoleChanged, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserHasAudioStream, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_CurrentUserHasVideoStream, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_SomeoneSharing, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewUserList, responder: self)
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_RenewSeatList, responder: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onAllUserCameraDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onAllUserMicrophoneDisableChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onInitialSelfUserInfo, observer: self)
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        debugPrint("deinit \(self)")
    }
}

// MARK: - Private
extension BottomViewModel {
    private func hasTUIChatItem() -> Bool {
        return TUICore.getService(TUICore_TUIChatService) != nil
    }
    
    private func changeItemSelectState(type: ButtonItemData.ButtonType, isSelected: Bool? = nil) {
        guard let item = viewItems.first(where: { $0.buttonType == type })
        else { return }
        if let isSelected = isSelected {
            item.isSelect = isSelected
        } else {
            item.isSelect = !item.isSelect
        }
        viewResponder?.updateButtonView(item: item)
    }
    
    private func updateRaiseHandItem() {
        guard roomInfo.isSeatEnabled else { return }
        raiseHandItem.normalTitle = currentUser.userRole == .generalUser ? .applyJoinStageText : .joinStageText
        leaveSeatHandItem.isSelect = false
        raiseHandItem.isSelect = false
        if currentUser.userRole == .roomOwner {
            guard let index = viewItems.firstIndex(where:{ $0.buttonType == .leaveSeatItemType || $0.buttonType == .raiseHandItemType }) else { return }
            viewItems.remove(at: index)
        } else if let index = viewItems.firstIndex(where:{ $0.buttonType == .leaveSeatItemType || $0.buttonType == .raiseHandItemType }) {
            if currentUser.isOnSeat {
                viewItems[index] = leaveSeatHandItem
            } else {
                viewItems[index] = raiseHandItem
            }
        } else {
            if currentUser.isOnSeat {
                addViewItem(buttonItem: leaveSeatHandItem, index: 3)
            } else {
                addViewItem(buttonItem: raiseHandItem, index: 1)
            }
        }
    }
    
    private func reorderTheMoreItem() {
        guard viewItems.count > 6 else { return }
        guard let index = viewItems.firstIndex(where: { $0.buttonType == .moreItemType }), index != 5 else { return }
        viewItems.remove(at: index)
        viewItems.insert(moreItem, at: 5)
    }
    
    private func removeViewItem(buttonType: ButtonItemData.ButtonType) {
        viewItems.removeAll(where: { $0.buttonType == buttonType })
    }
    
    private func addViewItem(buttonItem: ButtonItemData, index: Int) {
        guard !isContainedViewItem(buttonType: buttonItem.buttonType) else { return }
        if viewItems.count > index + 1 {
            viewItems.insert(buttonItem, at: index)
        } else {
            viewItems.append(buttonItem)
        }
    }
    
    private func isContainedViewItem(buttonType: ButtonItemData.ButtonType) -> Bool {
        return viewItems.contains(where: { $0.buttonType == buttonType })
    }
    
    private func updateAudioItem() {
        if roomInfo.isSeatEnabled, currentUser.userRole == .generalUser, !currentUser.isOnSeat {
            //If the audience in the room who raises their hand to speak is not on the microphone, the microphone button will not be displayed.
            removeViewItem(buttonType: .muteAudioItemType)
        } else if !isContainedViewItem(buttonType: .muteAudioItemType) {
            addViewItem(buttonItem: muteAudioItem, index: 1)
        }
        muteAudioItem.isSelect = !currentUser.hasAudioStream
        muteAudioItem.alpha = checkMicAuthority() || currentUser.hasAudioStream ? 1 : 0.5
    }
    
    private func updateVideoItem() {
        if roomInfo.isSeatEnabled, currentUser.userRole == .generalUser, !currentUser.isOnSeat {
            removeViewItem(buttonType: .muteVideoItemType)
        } else if !isContainedViewItem(buttonType: .muteVideoItemType) {
            addViewItem(buttonItem: muteVideoItem, index: 2)
        }
        muteVideoItem.isSelect = !currentUser.hasVideoStream
        muteVideoItem.alpha = checkCameraAuthority() || currentUser.hasVideoStream  ? 1 : 0.5
    }
    
    private func checkMicAuthority() -> Bool {
        if self.roomInfo.isMicrophoneDisableForAllUser && currentUser.userRole == .generalUser {
            return false
        }
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            return false
        }
        return true
    }
    
    private func checkCameraAuthority() -> Bool {
        if self.roomInfo.isCameraDisableForAllUser && currentUser.userRole == .generalUser {
            return false
        }
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            return false
        }
        return true
    }
    
    private func updateRaiseHandApplyItem() {
        guard roomInfo.isSeatEnabled else { return }
        raiseHandItem.normalTitle = currentUser.userRole == .generalUser ? .applyJoinStageText : .joinStageText
        if currentUser.userRole == .roomOwner {
            addViewItem(buttonItem: raiseHandApplyItem, index: 3)
        } else if currentUser.userRole == .administrator {
            addViewItem(buttonItem: raiseHandApplyItem, index: 4)
        } else {
            removeViewItem(buttonType: .raiseHandApplyItemType)
        }
    }
}

extension BottomViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_UserOnSeatChanged:
            guard roomInfo.isSeatEnabled else { return }
            updateRaiseHandItem()
            updateAudioItem()
            updateVideoItem()
            reorderTheMoreItem()
            viewResponder?.updateStackView(items: viewItems)
        case .TUIRoomKitService_CurrentUserRoleChanged:
            updateAudioItem()
            updateVideoItem()
            updateRaiseHandApplyItem()
            updateRaiseHandItem()
            reorderTheMoreItem()
            viewResponder?.updateStackView(items: viewItems)
        case .TUIRoomKitService_CurrentUserHasAudioStream:
            guard let hasAudio = info?["hasAudio"] as? Bool else { return }
            guard let reason = info?["reason"] as? TUIChangeReason else { return }
            if !hasAudio, reason == .byAdmin, !roomInfo.isMicrophoneDisableForAllUser {
                if !roomInfo.isSeatEnabled {
                    viewResponder?.makeToast(text: .noticeMicrophoneOffTitleText)
                } else if currentUser.isOnSeat {
                    viewResponder?.makeToast(text: .noticeMicrophoneOffTitleText)
                }
            }
            updateAudioItem()
            viewResponder?.updateButtonView(item: muteAudioItem)
        case .TUIRoomKitService_CurrentUserHasVideoStream:
            guard let hasVideo = info?["hasVideo"] as? Bool else { return }
            guard let reason = info?["reason"] as? TUIChangeReason else { return }
            if !hasVideo, reason == .byAdmin, !roomInfo.isCameraDisableForAllUser {
                if !roomInfo.isSeatEnabled {
                    viewResponder?.makeToast(text: .noticeCameraOffTitleText)
                } else if currentUser.isOnSeat {
                    viewResponder?.makeToast(text: .noticeCameraOffTitleText)
                }
            }
            updateVideoItem()
            viewResponder?.updateButtonView(item: muteVideoItem)
        case .TUIRoomKitService_SomeoneSharing:
            guard let userId = info?["userId"] as? String else { return }
            guard let hasVideo = info?["hasVideo"] as? Bool else { return }
            guard userId == currentUser.userId else { return }
            changeItemSelectState(type: .shareScreenItemType, isSelected: hasVideo)
            if !hasVideo {
                isCalledFromShareScreen = false
            }
        case .TUIRoomKitService_RenewUserList:
            memberItem.normalTitle = String(format: .memberText, attendeeList.count)
            viewResponder?.updateButtonView(item: memberItem)
        case .TUIRoomKitService_RenewSeatList:
            raiseHandApplyItem.noticeText = String(inviteSeatList.count)
            raiseHandApplyItem.hasNotice = inviteSeatList.count > 0
            viewResponder?.updateButtonView(item: raiseHandApplyItem)
        default: break
        }
    }
}

extension BottomViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onAllUserCameraDisableChanged:
            updateVideoItem()
            viewResponder?.updateButtonView(item: muteVideoItem)
        case .onAllUserMicrophoneDisableChanged:
            updateAudioItem()
            viewResponder?.updateButtonView(item: muteAudioItem)
        case .onInitialSelfUserInfo:
            updateAudioItem()
            updateVideoItem()
            updateRaiseHandApplyItem()
            updateRaiseHandItem()
            reorderTheMoreItem()
            viewResponder?.updateStackView(items: viewItems)
        default: break
        }
    }
}

private extension String {
    static var memberText: String {
        localized("Participants(%lld)")
    }
    static var muteAudioText: String {
        localized("Mute")
    }
    static var unMuteAudioText: String {
        localized("Unmute")
    }
    static var muteVideoText: String {
        localized("Stop video")
    }
    static var unMuteVideoText: String {
        localized("Start video")
    }
    static var stageManagementText: String {
        localized("Applies")
    }
    static var cancelStageText: String {
        localized("Cancel")
    }
    static var applyJoinStageText: String {
        localized("Join stage")
    }
    static var leaveSeatText: String {
        localized("Leave stage")
    }
    static var muteSeatReasonText: String {
        localized("Can be turned on after taking the stage")
    }
    static var muteAudioRoomReasonText: String {
        localized("All on mute audio, unable to turn on microphone")
    }
    static var muteVideoRoomReasonText: String {
        localized("All on mute video, unable to turn on camera")
    }
    static var noticeCameraOffTitleText: String {
        localized("The conference owner disabled your video.")
    }
    static var noticeMicrophoneOffTitleText: String {
        localized("You were muted by the host.")
    }
    static var shareScreenOnText: String {
        localized("Share")
    }
    static var shareScreenOffText: String {
        localized("Stop")
    }
    static var versionLowToastText: String {
        localized("Your system version is below 12.0. Please update.")
    }
    static var chatText: String {
        localized("Chat")
    }
    static var unfoldText: String {
        localized("More")
    }
    static var inviteText: String {
        localized("Invite")
    }
    static var floatText: String {
        localized("Floating")
    }
    static var setupText: String {
        localized("Settings")
    }
    static var dropText: String {
        localized("Drop")
    }
    static var rejectedTakeSeatText: String {
        localized("Application to go on stage was rejected")
    }
    static var takenSeatText: String {
        localized("Succeed on stage")
    }
    static var othersScreenSharingText: String {
        localized("An existing member is sharing. Please try again later")
    }
    static var toastTitleText: String {
        localized("Share Screen")
    }
    static var toastMessageText: String {
        localized("Stop TUIRoom screen sharing screen live?")
    }
    static var toastCancelText: String {
        localized("Cancel")
    }
    static var toastStopText: String {
        localized("Stop")
    }
    static var applicationHasSentText: String {
        localized("Application has been sent, please wait for the owner/administrator to approve")
    }
    static var joinStageText: String {
        localized("Join stage")
    }
    static var leaveSeatTitle: String {
        localized("Are you sure you want to step down?")
    }
    static var leaveSeatMessage: String {
        localized("To get on stage again, you need to resend the application and wait for the owner/administrator to approve it.")
    }
    static var joinStageApplicationCancelledText: String {
        localized("Application for stage has been cancelled")
    }
    static var joinStageApplicationTimedOutText: String {
        localized("The request to go on stage has timed out")
    }
}
