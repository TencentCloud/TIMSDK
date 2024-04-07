//
//  BottomViewModel.swift
//  Alamofire
//
//  Created by aby on 2022/12/22.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine
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
        EngineManager.createInstance()
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
    var isCalledFromShareScreen = false
    
    private lazy var memberItem: ButtonItemData = {
        let memberItem = ButtonItemData()
        memberItem.normalTitle = localizedReplace(.memberText,replace: String(attendeeList.count))
        memberItem.normalIcon = "room_member"
        memberItem.resourceBundle = tuiRoomKitBundle()
        memberItem.buttonType = .memberItemType
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
        chatItem.buttonType = .chatItemType
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
        floatItem.buttonType = .floatWindowItemType
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
        setupItem.buttonType = .setupItemType
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
        inviteItem.buttonType = .inviteItemType
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
        //如果房主全体静音，房间普通成员不可打开麦克风
        if self.roomInfo.isMicrophoneDisableForAllUser && currentUser.userRole == .generalUser {
            viewResponder?.makeToast(text: .muteAudioRoomReasonText)
            return
        }
        //如果是举手发言房间，并且没有上麦，不可打开麦克风
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
        //如果房主全体禁画，房间普通成员不可打开摄像头
        if self.roomInfo.isCameraDisableForAllUser && self.currentUser.userRole == .generalUser {
            viewResponder?.makeToast(text: .muteVideoRoomReasonText)
            return
        }
        //如果是举手发言房间，并且没有上麦，不可打开摄像头
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteSeatReasonText)
            return
        }
        engineManager.setLocalVideoView(streamType: .cameraStream, view: nil)
        engineManager.openLocalCamera()
    }
    
    func raiseHandApplyAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .raiseHandApplicationListViewType, height: 720.scale375Height())
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
                //如果有人正在进行屏幕共享，自己就不能再进行屏幕共享
                guard engineManager.store.attendeeList.first(where: {$0.hasScreenStream}) == nil else {
                    viewResponder?.makeToast(text: .othersScreenSharingText)
                    return
                }
                //如果现在是举手发言房间，自己又没有上麦，也不能进行屏幕共享
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
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        debugPrint("deinit \(self)")
    }
}

// MARK: - Private
extension BottomViewModel {
    private func hasTUIChatItem() -> Bool {
        return TUICore.getService(TUICore_TUIChatService) != nil
    }
    
    //修改item的点击情况，type用于区分item，isSelected用来设置点击状态，如果不传入isSelected则点击状态默认取反
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
    
    //更新申请上台按钮
    private func updateRaiseHandItem() {
        guard roomInfo.isSeatEnabled else { return }
        raiseHandItem.normalTitle = currentUser.userRole == .generalUser ? .applyJoinStageText : .joinStageText
        leaveSeatHandItem.isSelect = false
        raiseHandItem.isSelect = false
        if currentUser.userRole == .roomOwner {
            //房主不显示上台或者下台按钮
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
    
    //保持moreItem的位置，在第六位
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
            //举手发言房间观众不上麦，则不显示麦克风按钮
            removeViewItem(buttonType: .muteAudioItemType)
        } else if !isContainedViewItem(buttonType: .muteAudioItemType) {
            addViewItem(buttonItem: muteAudioItem, index: 1)
        }
        muteAudioItem.isSelect = !currentUser.hasAudioStream
        muteAudioItem.alpha = checkMicAuthority() || currentUser.hasAudioStream ? 1 : 0.5
    }
    
    private func updateVideoItem() {
        if roomInfo.isSeatEnabled, currentUser.userRole == .generalUser, !currentUser.isOnSeat {
            //举手发言房间观众不上麦，则不显示摄像头按钮
            removeViewItem(buttonType: .muteVideoItemType)
        } else if !isContainedViewItem(buttonType: .muteVideoItemType) {
            addViewItem(buttonItem: muteVideoItem, index: 2)
        }
        muteVideoItem.isSelect = !currentUser.hasVideoStream
        muteVideoItem.alpha = checkCameraAuthority() || currentUser.hasVideoStream  ? 1 : 0.5
    }
    //检查麦克风权限
    private func checkMicAuthority() -> Bool {
        //如果房主全体静音，房间普通成员没有麦克风权限
        if self.roomInfo.isMicrophoneDisableForAllUser && currentUser.userRole == .generalUser {
            return false
        }
        //如果是举手发言房间并且没有上麦，没有麦克风权限
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            return false
        }
        return true
    }
    //检查摄像头权限
    private func checkCameraAuthority() -> Bool {
        //如果房主全体静音，房间普通成员没有摄像头权限
        if self.roomInfo.isCameraDisableForAllUser && currentUser.userRole == .generalUser {
            return false
        }
        //如果是举手发言房间并且没有上麦，没有摄像头权限
        if roomInfo.isSeatEnabled, !currentUser.isOnSeat {
            return false
        }
        return true
    }
    
    private func updateRaiseHandApplyItem() {
        guard roomInfo.isSeatEnabled else { return }
        raiseHandItem.normalTitle = currentUser.userRole == .generalUser ? .applyJoinStageText : .joinStageText
        if currentUser.userRole == .roomOwner {
            //房主添加上台管理按钮
            addViewItem(buttonItem: raiseHandApplyItem, index: 3)
        } else if currentUser.userRole == .administrator {
            //管理员增加上台管理按钮
            addViewItem(buttonItem: raiseHandApplyItem, index: 4)
        } else {
            //普通观众去掉上台管理按钮
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
        case .TUIRoomKitService_RenewUserList, .TUIRoomKitService_RenewSeatList:
            memberItem.normalTitle = localizedReplace(.memberText,replace: String(attendeeList.count))
            viewResponder?.updateButtonView(item: memberItem)
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
        default: break
        }
    }
}

private extension String {
    static var memberText: String {
        localized("TUIRoom.member")
    }
    static var muteAudioText: String {
        localized("TUIRoom.mute")
    }
    static var unMuteAudioText: String {
        localized("TUIRoom.unmute")
    }
    static var muteVideoText: String {
        localized("TUIRoom.close.video")
    }
    static var unMuteVideoText: String {
        localized("TUIRoom.open.video")
    }
    static var stageManagementText: String {
        localized("TUIRoom.stage.management")
    }
    static var cancelStageText: String {
        localized("TUIRoom.cancel.stage")
    }
    static var applyJoinStageText: String {
        localized("TUIRoom.apply.join.stage")
    }
    static var leaveSeatText: String {
        localized("TUIRoom.leave.seat")
    }
    static var muteSeatReasonText: String {
        localized("TUIRoom.mute.seat.reason")
    }
    static var muteAudioRoomReasonText: String {
        localized("TUIRoom.mute.audio.room.reason")
    }
    static var muteVideoRoomReasonText: String {
        localized("TUIRoom.mute.video.room.reason")
    }
    static var noticeCameraOffTitleText: String {
        localized("TUIRoom.homeowners.notice.camera.turned.off")
    }
    static var noticeMicrophoneOffTitleText: String {
        localized("TUIRoom.homeowners.notice.microphone.turned.off")
    }
    static var shareScreenOnText: String {
        localized("TUIRoom.share.on")
    }
    static var shareScreenOffText: String {
        localized("TUIRoom.share.off")
    }
    static var versionLowToastText: String {
        localized("TUIRoom.version.too.low")
    }
    static var chatText: String {
        localized("TUIRoom.chat")
    }
    static var unfoldText: String {
        localized("TUIRoom.unfold")
    }
    static var inviteText: String {
        localized("TUIRoom.invite")
    }
    static var floatText: String {
        localized("TUIRoom.float")
    }
    static var setupText: String {
        localized("TUIRoom.setting")
    }
    static var dropText: String {
        localized("TUIRoom.drop")
    }
    static var rejectedTakeSeatText: String {
        localized("TUIRoom.rejected.take.seat")
    }
    static var takenSeatText: String {
        localized("TUIRoom.taken.seat")
    }
    static var othersScreenSharingText: String {
        localized("TUIRoom.others.screen.sharing")
    }
    static var toastTitleText: String {
        localized("TUIRoom.toast.shareScreen.title")
    }
    static var toastMessageText: String {
        localized("TUIRoom.toast.shareScreen.message")
    }
    static var toastCancelText: String {
        localized("TUIRoom.cancel")
    }
    static var toastStopText: String {
        localized("TUIRoom.toast.shareScreen.stop")
    }
    static var applicationHasSentText: String {
        localized("TUIRoom.join.stage.application.sent")
    }
    static var joinStageText: String {
        localized("TUIRoom.join.stage")
    }
    static var leaveSeatTitle: String {
        localized("TUIRoom.leave.seat.title")
    }
    static var leaveSeatMessage: String {
        localized("TUIRoom.leave.seat.message")
    }
    static var joinStageApplicationCancelledText: String {
        localized("TUIRoom.join.stage.application.cancelled")
    }
}
