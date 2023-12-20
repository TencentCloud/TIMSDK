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
    func updateStackView(item: ButtonItemData, index: Int)
    func makeToast(text: String)
    func updataBottomView(isUp:Bool)
    func showStopShareScreenAlert(sureBlock: (()->())?)
}

class BottomViewModel: NSObject {
    private(set) var viewItems: [ButtonItemData] = []
    private(set) var requestList: [String: String] = [:]
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
    
    var memberItem: ButtonItemData {
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
    }
    var muteAudioItem: ButtonItemData {
        let muteAudioItem = ButtonItemData()
        muteAudioItem.normalTitle = .muteAudioText
        muteAudioItem.selectedTitle = .unMuteAudioText
        muteAudioItem.normalIcon = "room_mic_on"
        muteAudioItem.selectedIcon = "room_mic_off"
        muteAudioItem.resourceBundle = tuiRoomKitBundle()
        muteAudioItem.buttonType = .muteAudioItemType
        muteAudioItem.isSelect = !currentUser.hasAudioStream
        muteAudioItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.muteAudioAction(sender: button)
        }
        return muteAudioItem
    }
    var muteVideoItem: ButtonItemData {
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
    }
    var shareScreenItem: ButtonItemData {
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
    }
    var chatItem: ButtonItemData {
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
    }
    var moreItem: ButtonItemData {
        let moreItem = ButtonItemData()
        moreItem.normalTitle = .unfoldText
        moreItem.normalIcon = "room_more"
        moreItem.resourceBundle = tuiRoomKitBundle()
        moreItem.buttonType = .moreItemType
        moreItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.moreAction(sender: button)
        }
        return moreItem
    }
    var floatItem: ButtonItemData {
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
    }
    var setupItem: ButtonItemData {
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
    }
    var recordItem: ButtonItemData {
        let recordItem = ButtonItemData()
        recordItem.normalTitle = .recordText
        recordItem.normalIcon = "room_record"
        recordItem.resourceBundle = tuiRoomKitBundle()
        recordItem.buttonType = .recordItemType
        recordItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.recordAction(sender: button)
        }
        return recordItem
    }
    var inviteItem: ButtonItemData {
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
    }
    var dropItem: ButtonItemData {
        let dropItem = ButtonItemData()
        dropItem.normalTitle = .dropText
        dropItem.normalIcon = "room_drop"
        dropItem.resourceBundle = tuiRoomKitBundle()
        dropItem.buttonType = .dropItemType
        dropItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.dropAction(sender: button)
        }
        return dropItem
    }
    
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
        if roomInfo.speechMode == .applySpeakAfterTakingSeat {
            //举手
            if currentUser.userId == roomInfo.ownerId || !currentUser.isOnSeat {
                viewItems.append(getItemOnRaiseHand())
            } else {
                viewItems.append(getItemOnLeaveSeat())
            }
        }
        viewItems.append(shareScreenItem)
        if hasTUIChatItem() {
            viewItems.append(chatItem)
        }
        viewItems.append(moreItem)
    }
    
    func createMoreBottomData(){
        viewItems.append(inviteItem)
        viewItems.append(floatItem)
        viewItems.append(setupItem)
        viewItems.append(dropItem)
        viewItems.append(recordItem)
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
        //如果房主全体静音，房间成员不可打开麦克风
        if self.roomInfo.isMicrophoneDisableForAllUser && self.currentUser.userId != roomInfo.ownerId {
            viewResponder?.makeToast(text: .muteAudioRoomReasonText)
            return
        }
        //如果是举手发言房间，并且没有上麦，不可打开麦克风
        if roomInfo.speechMode == .applySpeakAfterTakingSeat, !currentUser.isOnSeat {
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
        //如果房主全体禁画，房间成员不可打开摄像头
        if self.roomInfo.isCameraDisableForAllUser && self.currentUser.userId != roomInfo.ownerId {
            viewResponder?.makeToast(text: .muteVideoRoomReasonText)
            return
        }
        //如果是举手发言房间，并且没有上麦，不可打开摄像头
        if roomInfo.speechMode == .applySpeakAfterTakingSeat, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteSeatReasonText)
            return
        }
        engineManager.setLocalVideoView(streamType: .cameraStream, view: nil)
        engineManager.openLocalCamera()
    }
    
    func raiseHandAction(sender: UIButton) {
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        if currentUser.userId == roomInfo.ownerId {
            RoomRouter.shared.presentPopUpViewController(viewType: .raiseHandApplicationListViewType, height: 720.scale375Height())
        } else {
            changeItemSelectState(type: .raiseHandItemType)
            guard let item = getItem(type: .raiseHandItemType) else { return }
            if item.isSelect {
                let request = engineManager.takeSeat() { [weak self] _,_ in
                    guard let self = self else { return }
                    self.viewResponder?.makeToast(text: .takenSeatText)
                } onRejected: { [weak self] _, _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateToRaiseHand()
                    self.viewResponder?.makeToast(text: .rejectedTakeSeatText)
                } onCancelled: { [weak self] _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateToRaiseHand()
                } onTimeout: { [weak self] _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateToRaiseHand()
                } onError: { [weak self] _, _, code, message in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateToRaiseHand()
                    self.viewResponder?.makeToast(text: message)
                }
                requestList["takeSeat"] = request.requestId
                viewResponder?.makeToast(text: .raisedHandText)
            } else {
                guard let requestId = requestList["takeSeat"] else { return }
                engineManager.cancelRequest(requestId)
                viewResponder?.makeToast(text: .putHandsDownText)
            }
        }
    }
    
    func leaveSeatAction(sender: UIButton) {
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        changeItemSelectState(type: .leaveSeatItemType)
        engineManager.leaveSeat()
        changeItemStateToRaiseHand()
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
                guard !(roomInfo.speechMode == .applySpeakAfterTakingSeat && !currentUser.isOnSeat) else {
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
                viewResponder?.showStopShareScreenAlert(sureBlock: { [weak self] in
                    guard let self = self else { return }
                    self.engineManager.stopScreenCapture()
                })
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
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": false])
        if let viewResponder = self.viewResponder {
            viewResponder.updataBottomView(isUp: true)
        }
    }
    
    func inviteAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .inviteViewType, height: 186)
    }
    
    func floatAction(sender: UIButton) {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ShowRoomVideoFloatView, param: [:])
    }
    
    func recordAction(sender: UIButton) {
        
    }
    
    func setupAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .mediaSettingViewType, height: 709.scale375Height())
    }
    
    func dropAction(sender: UIButton) {
        engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
        if let viewResponder = self.viewResponder {
            viewResponder.updataBottomView(isUp: false)
        }
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
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        debugPrint("deinit \(self)")
    }
}

// MARK: - Private
extension BottomViewModel {
    private func getItem(type: ButtonItemData.ButtonType) -> ButtonItemData? {
        guard let item = viewItems.first(where: { $0.buttonType == type }) else { return nil }
        return item
    }
    
    private func getItemIndex(type: ButtonItemData.ButtonType) -> Int? {
        guard let index = viewItems.firstIndex(where: { $0.buttonType == type }) else { return nil }
        return index
    }
    
    private func hasTUIChatItem() -> Bool {
        return TUICore.getService(TUICore_TUIChatService) != nil
    }
    
    //修改item的点击情况，type用于区分item，isSelected用来设置点击状态，如果不传入isSelected则点击状态默认取反
    private func changeItemSelectState(type: ButtonItemData.ButtonType, isSelected: Bool? = nil) {
        guard let item = viewItems.first(where: { $0.buttonType == type })
        else { return }
        guard let itemIndex = viewItems.firstIndex(where: { $0.buttonType == type })
        else { return }
        if let isSelected = isSelected {
            item.isSelect = isSelected
        } else {
            item.isSelect = !item.isSelect
        }
        viewResponder?.updateStackView(item: item, index: itemIndex)
    }
    
    //举手按钮变成下台状态
    private func changeItemStateToLeaveSeat() {
        guard let index = viewItems.firstIndex(where:{ $0.buttonType == .leaveSeatItemType || $0.buttonType == .raiseHandItemType })
        else { return }
        viewItems[index] = getItemOnLeaveSeat()
        viewResponder?.updateStackView(item: getItemOnLeaveSeat(), index: index)
    }
    //举手按钮变成举手状态
    private func changeItemStateToRaiseHand() {
        guard let index = viewItems.firstIndex(where:{ $0.buttonType == .leaveSeatItemType || $0.buttonType == .raiseHandItemType })
        else { return }
        viewItems[index] = getItemOnRaiseHand()
        viewResponder?.updateStackView(item: getItemOnRaiseHand(), index: index)
    }
    
    private func getItemOnRaiseHand() -> ButtonItemData {
        let raiseHandItem = ButtonItemData()
        if currentUser.userId == roomInfo.ownerId {
            raiseHandItem.normalTitle = .raiseHandApplyListText
        } else {
            raiseHandItem.normalTitle = .raiseHandApplyText
        }
        raiseHandItem.normalIcon = "room_hand_raise"
        raiseHandItem.selectedIcon = "room_hand_down"
        raiseHandItem.selectedTitle = .handDownText
        raiseHandItem.resourceBundle = tuiRoomKitBundle()
        raiseHandItem.buttonType = .raiseHandItemType
        raiseHandItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.raiseHandAction(sender: button)
        }
        return raiseHandItem
    }
    
    private func getItemOnLeaveSeat() -> ButtonItemData {
        let raiseHandItem = ButtonItemData()
        raiseHandItem.normalIcon = "room_leaveSeat"
        raiseHandItem.selectedIcon = "room_hand_raise"
        raiseHandItem.normalTitle = .leaveSeatText
        raiseHandItem.selectedTitle = .raiseHandText
        raiseHandItem.buttonType = .leaveSeatItemType
        raiseHandItem.resourceBundle = tuiRoomKitBundle()
        raiseHandItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.leaveSeatAction(sender: button)
        }
        return raiseHandItem
    }
}


extension BottomViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_UserOnSeatChanged:
            guard roomInfo.speechMode == .applySpeakAfterTakingSeat else { return }
            guard let isOnSeat = info?["isOnSeat"] as? Bool else { return }
            changeItemSelectState(type: .muteAudioItemType, isSelected: !currentUser.hasAudioStream)
            changeItemSelectState(type: .muteVideoItemType, isSelected: !currentUser.hasVideoStream)
            //如果自己就是房主，上麦不需要更改举手发言的button
            guard currentUser.userId != roomInfo.ownerId else { return }
            if isOnSeat {
                changeItemStateToLeaveSeat()
            } else {
                changeItemStateToRaiseHand()
            }
        case .TUIRoomKitService_CurrentUserRoleChanged:
            engineManager.fetchRoomInfo() { [weak self] in
                guard let self = self else { return }
                if self.roomInfo.ownerId == self.currentUser.userId {
                    self.changeItemStateToRaiseHand()
                } else {
                    if self.currentUser.isOnSeat {
                        self.changeItemStateToLeaveSeat()
                    } else {
                        self.changeItemStateToRaiseHand()
                    }
                }
            }
        case .TUIRoomKitService_CurrentUserHasAudioStream:
            guard let hasAudio = info?["hasAudio"] as? Bool else { return }
            guard let reason = info?["reason"] as? TUIChangeReason else { return }
            if !hasAudio, reason == .byAdmin, !roomInfo.isMicrophoneDisableForAllUser {
                viewResponder?.makeToast(text: .noticeMicrophoneOffTitleText)
            }
            changeItemSelectState(type: .muteAudioItemType, isSelected: !currentUser.hasAudioStream)
        case .TUIRoomKitService_CurrentUserHasVideoStream:
            guard let hasVideo = info?["hasVideo"] as? Bool else { return }
            guard let reason = info?["reason"] as? TUIChangeReason else { return }
            if !hasVideo, reason == .byAdmin, !roomInfo.isCameraDisableForAllUser {
                viewResponder?.makeToast(text: .noticeCameraOffTitleText)
            }
            changeItemSelectState(type: .muteVideoItemType, isSelected: !currentUser.hasVideoStream)
        case .TUIRoomKitService_SomeoneSharing:
            guard let userId = info?["userId"] as? String else { return }
            guard let hasVideo = info?["hasVideo"] as? Bool else { return }
            guard userId == currentUser.userId else { return }
            changeItemSelectState(type: .shareScreenItemType, isSelected: hasVideo)
            if !hasVideo {
                isCalledFromShareScreen = false
            }
        case .TUIRoomKitService_RenewUserList, .TUIRoomKitService_RenewSeatList:
            guard let item = getItem(type: .memberItemType) else { return }
            guard let index = getItemIndex(type: .memberItemType) else { return }
            item.normalTitle = localizedReplace(.memberText,replace: String(attendeeList.count))
            viewResponder?.updateStackView(item: item, index: index)
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
    static var raiseHandApplyText: String {
        localized("TUIRoom.raise.hand")
    }
    static var raiseHandApplyListText: String {
        localized("TUIRoom.raise.hand.list")
    }
    static var handDownText: String {
        localized("TUIRoom.hand.down")
    }
    static var raiseHandText: String {
        localized("TUIRoom.raise.hand")
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
    static var recordText: String {
        localized("TUIRoom.record")
    }
    static var setupText: String {
        localized("TUIRoom.setting")
    }
    static var dropText: String {
        localized("TUIRoom.drop")
    }
    static var putHandsDownText: String {
        localized("TUIRoom.put.hands.down")
    }
    static var raisedHandText: String {
        localized("TUIRoom.raised.hand")
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
}
