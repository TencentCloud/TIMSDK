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
    func updateButtonItemViewSelectState(shareScreenSeletecd: Bool)
    func updateButtonItemViewEnableState(shareScreenEnable: Bool)
    func reloadBottomView()
}

class BottomViewModel: NSObject {
    private(set) var viewItems: [ButtonItemData] = []
    private(set) var requestList: [String: String] = [:]
    var timeoutNumber: Double = 0
    weak var viewResponder: BottomViewModelResponder?
    private enum ViewItemNumber: Int {
        case normalItem
        case muteAudioItem
        case muteVideoItem
        case raiseHandItem
        case memberItem
        case moreItem
        case inviteItem
        case floatItem
        case recordItem
        case setupItem
        case dropItem
        case shareItem
    }
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
        memberItem.normalTitle = .memberText
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
        if engineManager.store.attendeeList.first(where: {$0.hasScreenStream}) != nil {
            shareScreenItem.isEnabled = false
        }else{
            shareScreenItem.isEnabled = true
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
            self.engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": false])
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
            self.engineEventCenter.notifyUIEvent(key: .TUIRoomKitService_SetToolBarDelayHidden, param: ["isDelay": true])
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
        EngineEventCenter.shared.subscribeEngine(event: .onUserScreenCaptureStopped, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserVideoStateChanged, observer: self)
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
    
    private func hasTUIChatItem() -> Bool {
        return TUICore.getService(TUICore_TUIChatService) != nil
    }
    
    func memberAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .userListViewType, height: 708.scale375Height(),backgroundColor: UIColor(0x17181F))
    }
    
    func muteAudioAction(sender: UIButton) {
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
            viewResponder?.makeToast(text: .muteAudioSeatReasonText)
            return
        }
        self.engineManager.unmuteLocalAudio()
    }
    
    func muteVideoAction(sender: UIButton) {
        if currentUser.hasVideoStream {
            engineManager.closeLocalCamera()
            return
        }
        //如果房主全体禁画，房间成员不可打开摄像头
        if self.roomInfo.isCameraDisableForAllUser && self.currentUser.userId != roomInfo.ownerId {
            viewResponder?.makeToast(text: .muteVideoRoomReasonText)
            return
        }
        //如果是举手发言房间，并且没有上麦，不可打开麦克风
        if roomInfo.speechMode == .applySpeakAfterTakingSeat, !currentUser.isOnSeat {
            viewResponder?.makeToast(text: .muteVideoSeatReasonText)
            return
        }
        engineManager.setLocalVideoView(streamType: .cameraStream, view: nil)
        engineManager.openLocalCamera()
    }
    
    func raiseHandAction(sender: UIButton) {
        if currentUser.userId == roomInfo.ownerId {
            RoomRouter.shared.presentPopUpViewController(viewType: .raiseHandApplicationListViewType, height: nil)
        } else {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                let request = engineManager.takeSeat() { [weak self] _,_ in
                    guard let self = self else { return }
                    self.viewResponder?.makeToast(text: .takenSeatText)
                } onRejected: { [weak self] _, _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateForRaiseHand()
                    self.viewResponder?.makeToast(text: .rejectedTakeSeatText)
                } onCancelled: { [weak self] _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateForRaiseHand()
                } onTimeout: { [weak self] _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateForRaiseHand()
                } onError: { [weak self] _, _, code, message in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateForRaiseHand()
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
        sender.isSelected = !sender.isSelected
        engineManager.leaveSeat()
        changeItemStateForRaiseHand()
    }
    
    func shareScreenAction(sender: UIButton) {
        if #available(iOS 12.0, *) {
            if !sender.isSelected {
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
            }else {
                let alertVC = UIAlertController(title: .toastTitleText,
                                                message: .toastMessageText,
                                                preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: .toastCancelText, style: .cancel) { _ in
                }
                let StopAction = UIAlertAction(title: .toastStopText, style: .default) { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    self.engineManager.stopScreenCapture()
                }
                alertVC.addAction(cancelAction)
                alertVC.addAction(StopAction)
                RoomRouter.shared.presentAlert(alertVC)
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
        if let viewResponder = self.viewResponder {
            viewResponder.updataBottomView(isUp: true)
        }
    }
    
    func inviteAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .inviteViewType, height: 186)
    }
    
    func floatAction(sender: UIButton) {
        EngineEventCenter.shared.notifyUIEvent(key: .TUIRoomKitService_ShowRoomFloatView, param: [:])
    }
    
    func recordAction(sender: UIButton) {
        
    }
    
    func setupAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        RoomRouter.shared.presentPopUpViewController(viewType: .setUpViewType, height: 300.scale375())
    }
    
    func dropAction(sender: UIButton) {
        if let viewResponder = self.viewResponder {
            viewResponder.updataBottomView(isUp: false)
        }
    }
    
    //举手按钮变成下台状态
    private func changeItemStateForLeaveSeat() {
        guard viewItems.first(where: { $0.buttonType == .leaveSeatItemType || $0.buttonType == .raiseHandItemType  }) != nil
        else { return }
        viewResponder?.updateStackView(item: getItemOnLeaveSeat(), index: ViewItemNumber.raiseHandItem.rawValue)
    }
    //举手按钮变成举手状态
    private func changeItemStateForRaiseHand() {
        guard viewItems.first(where: { $0.buttonType == .leaveSeatItemType || $0.buttonType == .raiseHandItemType }) != nil
        else { return }
        viewResponder?.updateStackView(item: getItemOnRaiseHand(), index: ViewItemNumber.raiseHandItem.rawValue)
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
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserScreenCaptureStopped, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVideoStateChanged, observer: self)
        NotificationCenter.default.removeObserver(self, name: UIScreen.capturedDidChangeNotification, object: nil)
        debugPrint("deinit \(self)")
    }
}

extension BottomViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        switch key {
        case .TUIRoomKitService_UserOnSeatChanged:
            guard roomInfo.speechMode == .applySpeakAfterTakingSeat else { return }
            guard let isOnSeat = info?["isOnSeat"] as? Bool else { return }
            guard let muteAudioItem = viewItems.first(where: { $0.buttonType == .muteAudioItemType }) else { return }
            muteAudioItem.isSelect = !currentUser.hasAudioStream
            viewResponder?.updateStackView(item: muteAudioItem, index: ViewItemNumber.muteAudioItem.rawValue)
            guard let muteVideoItem = viewItems.first(where: { $0.buttonType == .muteVideoItemType }) else { return }
            muteVideoItem.isSelect = !currentUser.hasVideoStream
            viewResponder?.updateStackView(item: muteVideoItem, index: ViewItemNumber.muteVideoItem.rawValue)
            //如果自己就是房主，上麦不需要更改举手发言的button
            guard currentUser.userId != roomInfo.ownerId else { return }
            if isOnSeat {
                changeItemStateForLeaveSeat()
            } else {
                changeItemStateForRaiseHand()
            }
        case .TUIRoomKitService_CurrentUserRoleChanged:
            guard let userRole = info?["userRole"] as? TUIRole else { return }
            switch userRole {
            case .roomOwner :
                changeItemStateForRaiseHand()
            case .generalUser:
                if currentUser.isOnSeat {
                    changeItemStateForLeaveSeat()
                } else {
                    changeItemStateForRaiseHand()
                }
            default: break
            }
        case .TUIRoomKitService_CurrentUserHasAudioStream:
            guard let hasAudio = info?["hasAudio"] as? Bool else { return }
            guard let reason = info?["reason"] as? TUIChangeReason else { return }
            if !hasAudio, reason == .byAdmin, !roomInfo.isMicrophoneDisableForAllUser {
                viewResponder?.makeToast(text: .noticeMicrophoneOffTitleText)
            }
            guard let audioItem = viewItems.first(where: { $0.buttonType == .muteAudioItemType }) else { return }
            audioItem.isSelect = !currentUser.hasAudioStream
            viewResponder?.updateStackView(item: audioItem, index: ViewItemNumber.muteAudioItem.rawValue)
        case .TUIRoomKitService_CurrentUserHasVideoStream:
            guard let hasVideo = info?["hasVideo"] as? Bool else { return }
            guard let reason = info?["reason"] as? TUIChangeReason else { return }
            if !hasVideo, reason == .byAdmin, !roomInfo.isCameraDisableForAllUser {
                viewResponder?.makeToast(text: .noticeCameraOffTitleText)
            }
            guard let videoItem = viewItems.first(where: { $0.buttonType == .muteVideoItemType }) else { return }
            videoItem.isSelect = !currentUser.hasVideoStream
            viewResponder?.updateStackView(item: videoItem, index: ViewItemNumber.muteVideoItem.rawValue)
        case .TUIRoomKitService_SomeoneSharing:
            if let sharingUser = engineManager.store.attendeeList.first(where: {$0.hasScreenStream}){
                viewResponder?.updateButtonItemViewEnableState(shareScreenEnable: sharingUser.userId == currentUser.userId)
            }
        case .TUIRoomKitService_RenewUserList, .TUIRoomKitService_RenewSeatList:
            viewResponder?.reloadBottomView()
        default: break
        }
    }
}

extension BottomViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String: Any]?){
        switch name {
        case .onUserScreenCaptureStopped:
            isCalledFromShareScreen = false
            viewResponder?.updateButtonItemViewSelectState(shareScreenSeletecd: false)
        case .onUserVideoStateChanged:
            guard let userId = param?["userId"] as? String, let streamType = param?["streamType"] as? TUIVideoStreamType,
                  let hasVideo =  param?["hasVideo"] as? Bool else{return}
            if userId == currentUser.userId,streamType == .screenStream,
               hasVideo == true {
                viewResponder?.updateButtonItemViewSelectState(shareScreenSeletecd: true)
            }
            if streamType == .screenStream && hasVideo == false {
                viewResponder?.updateButtonItemViewEnableState(shareScreenEnable: true)
            }
        default:
            break
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
    static var muteAudioSeatReasonText: String {
        localized("TUIRoom.mute.audio.seat.reason")
    }
    static var muteVideoSeatReasonText: String {
        localized("TUIRoom.mute.video.seat.reason")
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
    static var toastTitleText: String {
        localized("TUIRoom.toast.shareScreen.title")
    }
    static var toastMessageText: String {
        localized("TUIRoom.toast.shareScreen.message")
    }
    static var toastCancelText: String {
        localized("TUIRoom.toast.shareScreen.cancel")
    }
    static var toastStopText: String {
        localized("TUIRoom.toast.shareScreen.stop")
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
}
