//
//  BottomViewModel.swift
//  Alamofire
//
//  Created by aby on 2022/12/22.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

protocol BottomViewModelResponder: AnyObject {
    func updateStackView(item: ButtonItemData, index: Int)
    func makeToast(text: String)
    func showExitRoomAlert(isRoomOwner: Bool, isOnlyOneUserInRoom: Bool)
}

class BottomViewModel: NSObject {
    private(set) var viewItems: [ButtonItemData] = []
    private(set) var requestList: [String: String] = [:]
    var timeoutNumber: Double = 30
    weak var viewResponder: BottomViewModelResponder?
    private enum ViewItemNumber: Int {
        case normalItem
        case muteAudioItem
        case muteVideoItem
        case raiseHandItem
        case memberItem
        case moreItem
    }
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    var currentUser: UserModel {
        engineManager.store.currentUser
    }
    
    override init() {
        super.init()
        createBottomData()
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, responder: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.subscribeEngine(event: .onUserVideoStateChanged, observer: self)
    }
    
    func createBottomData() {
        //离开房间
        let exitItem = ButtonItemData()
        exitItem.normalTitle = .exitText
        exitItem.normalIcon = "room_exit"
        exitItem.backgroundColor = UIColor(0xD52E4A)
        exitItem.resourceBundle = tuiRoomKitBundle()
        exitItem.buttonType = .exitItemType
        exitItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.exitAction(sender: button)
        }
        viewItems.append(exitItem)
        // 静音
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
        viewItems.append(muteAudioItem)
        // 静画
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
        viewItems.append(muteVideoItem)
        if roomInfo.speechMode == .applySpeakAfterTakingSeat {
            //举手
            if currentUser.userRole == .roomOwner || !currentUser.isOnSeat {
                viewItems.append(getItemOnRaiseHand())
            } else {
                viewItems.append(getItemOnLeaveSeat())
            }
        }
        // 成员列表
        let memberItem = ButtonItemData()
        memberItem.normalTitle = .memberText
        memberItem.normalIcon = "room_member"
        memberItem.resourceBundle = tuiRoomKitBundle()
        memberItem.buttonType = .memberItemType
        memberItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.memberAction(sender: button)
        }
        viewItems.append(memberItem)
        // 更多
        let moreItem = ButtonItemData()
        moreItem.normalIcon = "room_more"
        moreItem.resourceBundle = tuiRoomKitBundle()
        moreItem.buttonType = .moreItemType
        moreItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.moreAction(sender: button)
        }
        viewItems.append(moreItem)
    }
    
    func exitAction(sender: UIButton) {
        let isRoomOwner: Bool = currentUser.userRole == .roomOwner
        let isOnlyOneUserInRoom: Bool = engineManager.store.attendeeList.count == 1
        viewResponder?.showExitRoomAlert(isRoomOwner: isRoomOwner, isOnlyOneUserInRoom: isOnlyOneUserInRoom)
    }
    
    func exitRoom(isHomeowner: Bool) {
        if isHomeowner {
            engineManager.destroyRoom(onSuccess: nil, onError: nil)
        } else {
            engineManager.exitRoom(onSuccess: nil, onError: nil)
        }
        RoomRouter.shared.dismissAllRoomPopupViewController()
        RoomRouter.shared.popToRoomEntranceViewController()
    }
    
    func muteAudioAction(sender: UIButton) {
        if !sender.isSelected {
            engineManager.closeLocalMicrophone()
            return
        }
        //如果房主全体静音，房间成员不可打开麦克风
        if self.roomInfo.isMicrophoneDisableForAllUser && self.currentUser.userRole != .roomOwner {
            viewResponder?.makeToast(text: .muteAudioRoomReasonText)
            return
        }
        switch roomInfo.speechMode {
        case .freeToSpeak:
            engineManager.openLocalMicrophone()
        case .applySpeakAfterTakingSeat:
            if currentUser.isOnSeat {
                engineManager.openLocalMicrophone()
            } else {
                viewResponder?.makeToast(text: .muteAudioSeatReasonText)
            }
        case .applyToSpeak:
                engineManager.applyToAdminToOpenLocalDevice(device: .microphone, timeout: timeoutNumber)
        @unknown default:
            break
        }
    }
    
    func muteVideoAction(sender: UIButton) {
        if !sender.isSelected {
            engineManager.closeLocalCamera()
            return
        }
        //如果房主全体禁画，房间成员不可打开摄像头
        if self.roomInfo.isCameraDisableForAllUser && self.currentUser.userRole != .roomOwner {
            viewResponder?.makeToast(text: .muteVideoRoomReasonText)
            return
        }
        engineManager.roomEngine.setLocalVideoView(streamType: .cameraStream, view: nil)
        switch roomInfo.speechMode {
        case .freeToSpeak:
            engineManager.openLocalCamera()
        case .applySpeakAfterTakingSeat:
            if currentUser.isOnSeat {
                engineManager.openLocalCamera()
            } else {
                viewResponder?.makeToast(text: .muteVideoSeatReasonText)
            }
        case .applyToSpeak:
                engineManager.applyToAdminToOpenLocalDevice(device: .camera, timeout: timeoutNumber)
        @unknown default:
            break
        }
    }
    
    func raiseHandAction(sender: UIButton) {
        if currentUser.userRole == .roomOwner {
            RoomRouter.shared.presentPopUpViewController(viewType: .raiseHandApplicationListViewType, height: nil)
        } else {
            sender.isSelected = !sender.isSelected
            if sender.isSelected {
                let request = engineManager.roomEngine.takeSeat(-1, timeout: timeoutNumber) { [weak self] _, _ in
                    guard let self = self else { return }
                    self.currentUser.isOnSeat = true
                } onRejected: { [weak self] _, _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateForRaiseHand()
                } onCancelled: { [weak self] _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateForRaiseHand()
                } onTimeout: { [weak self] _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateForRaiseHand()
                } onError: { [weak self] _, _, _, _ in
                    guard let self = self else { return }
                    self.requestList.removeValue(forKey: "takeSeat")
                    self.changeItemStateForRaiseHand()
                }
                requestList["takeSeat"] = request.requestId
            } else {
                guard let requestId = requestList["takeSeat"] else { return }
                engineManager.roomEngine.cancelRequest(requestId) {
                } onError: { code, message in
                    debugPrint("cancelRequest:code:\(code),message:\(message)")
                }
            }
        }
    }
    
    func leaveSeatAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        engineManager.roomEngine.leaveSeat {
        } onError: { code, message in
            debugPrint("leaveSeat:code:\(code),message:\(message)")
        }
        changeItemStateForRaiseHand()
    }
    
    func memberAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .userListViewType, height: nil)
    }
    
    func moreAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .moreViewType, height: 179.scale375())
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
        if currentUser.userRole == .roomOwner {
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
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_UserOnSeatChanged, responder: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserRoleChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserAudioStateChanged, observer: self)
        EngineEventCenter.shared.unsubscribeEngine(event: .onUserVideoStateChanged, observer: self)
        debugPrint("deinit \(self)")
    }
}

extension BottomViewModel: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        if key == .TUIRoomKitService_UserOnSeatChanged && roomInfo.speechMode == .applySpeakAfterTakingSeat {
            guard let isOnSeat = info?["isOnSeat"] as? Bool else { return }
            guard let muteAudioItem = viewItems.first(where: { $0.buttonType == .muteAudioItemType }) else { return }
            muteAudioItem.isSelect = !currentUser.hasAudioStream
            viewResponder?.updateStackView(item: muteAudioItem, index: ViewItemNumber.muteAudioItem.rawValue)
            guard let muteVideoItem = viewItems.first(where: { $0.buttonType == .muteVideoItemType }) else { return }
            muteVideoItem.isSelect = !currentUser.hasVideoStream
            viewResponder?.updateStackView(item: muteVideoItem, index: ViewItemNumber.muteVideoItem.rawValue)
            //如果自己就是房主，上麦不需要更改举手发言的button
            guard currentUser.userRole != .roomOwner else { return }
            if isOnSeat {
                changeItemStateForLeaveSeat()
            } else {
                changeItemStateForRaiseHand()
            }
            
        }
    }
}

extension BottomViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        if name == .onUserRoleChanged {
            guard let userRole = param?["userRole"] as? TUIRole else { return }
            guard let userId = param?["userId"] as? String else { return }
            guard userId == currentUser.userId else { return }
            currentUser.userRole = userRole
            // 如果转换房主的时候，用户是房主
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
        }
        if name == .onUserVideoStateChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let streamType = param?["streamType"] as? TUIVideoStreamType else { return }
            guard let hasVideo = param?["hasVideo"] as? Bool else { return }
            guard let reason = param?["reason"] as? TUIChangeReason else { return }
            switch streamType {
            case .cameraStream:
                if userId == currentUser.userId {
                    currentUser.hasVideoStream = hasVideo
                    if !hasVideo, reason == .byAdmin {
                        viewResponder?.makeToast(text: .noticeCameraOffTitleText)
                    }
                    guard let videoItem = viewItems.first(where: { $0.buttonType == .muteVideoItemType }) else { return }
                    videoItem.isSelect = !currentUser.hasVideoStream
                    viewResponder?.updateStackView(item: videoItem, index: ViewItemNumber.muteVideoItem.rawValue)
                }
            default: break
            }
        }
        if name == .onUserAudioStateChanged {
            guard let userId = param?["userId"] as? String else { return }
            guard let hasAudio = param?["hasAudio"] as? Bool else { return }
            guard let reason = param?["reason"] as? TUIChangeReason else { return }
            if userId == currentUser.userId {
                currentUser.hasAudioStream = hasAudio
                if !hasAudio, reason == .byAdmin {
                    viewResponder?.makeToast(text: .noticeMicrophoneOffTitleText)
                }
                guard let audioItem = viewItems.first(where: { $0.buttonType == .muteAudioItemType }) else { return }
                audioItem.isSelect = !currentUser.hasAudioStream
                viewResponder?.updateStackView(item: audioItem, index: ViewItemNumber.muteAudioItem.rawValue)
            }
        }
    }
}

private extension String {
    static var exitText: String {
        localized("TUIRoom.leave")
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
    static var memberText: String {
        localized("TUIRoom.member")
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
}
