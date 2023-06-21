//
//  CreateRoomViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2022/12/29.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

protocol CreateViewEventResponder: AnyObject {
    func updateInputStackView(item: ListCellItemData, index: Int) -> Void
    func showSpeechModeControlView() -> Void
}

class CreateRoomViewModel {
    
    private(set) var inputViewItems: [ListCellItemData] = []
    private(set) var switchViewItems: [ListCellItemData] = []
    private var speechMode: TUISpeechMode = .freeToSpeak
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var currentUser: UserModel {
        engineManager.store.currentLoginUser
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    lazy var roomId: String = {
        let userId = currentUser.userId
        let result = "\(String(describing: userId))_room_kit".hash & 0x3B9AC9FF
        return String(result)
    }()
    
    weak var responder: CreateViewEventResponder?
    
    init() {
        speechMode = engineManager.store.roomSpeechMode
        initialState()
        creatEntranceViewModel()
    }
    
    func initialState() {
        roomInfo.roomId = roomId
    }
    
    func creatEntranceViewModel() {
        let roomTypeItem = ListCellItemData()
        roomTypeItem.titleText = .roomTypeText
        switch engineManager.store.roomSpeechMode {
        case .freeToSpeak:
            roomTypeItem.messageText = .freedomSpeakText
        case .applySpeakAfterTakingSeat:
            roomTypeItem.messageText = .raiseHandSpeakText
        default: break
        }
        roomTypeItem.hasButton = true
        roomTypeItem.hasOverAllAction = true
        roomTypeItem.action = { [weak self] sender in
            guard let self = self else { return }
            self.switchRoomTypeClick()
        }
        inputViewItems.append(roomTypeItem)
        
        let createRoomIdItem = ListCellItemData()
        createRoomIdItem.titleText = .roomNumText
        createRoomIdItem.messageText = roomInfo.roomId
        inputViewItems.append(createRoomIdItem)
        
        let userNameItem = ListCellItemData()
        userNameItem.titleText = .userNameText
        userNameItem.messageText = currentUser.userName
        inputViewItems.append(userNameItem)
        
        let openMicItem = ListCellItemData()
        openMicItem.titleText = .openMicText
        openMicItem.hasSwitch = true
        openMicItem.isSwitchOn = roomInfo.isOpenMicrophone
        openMicItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.roomInfo.isOpenMicrophone = view.isOn
        }
        switchViewItems.append(openMicItem)
        
        let openSpeakerItem = ListCellItemData()
        openSpeakerItem.titleText = .openSpeakerText
        openSpeakerItem.hasSwitch = true
        openSpeakerItem.isSwitchOn = roomInfo.isUseSpeaker
        openSpeakerItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.roomInfo.isUseSpeaker = view.isOn
        }
        switchViewItems.append(openSpeakerItem)
        
        let openCameraItem = ListCellItemData()
        openCameraItem.titleText = .openCameraText
        openCameraItem.hasSwitch = true
        openCameraItem.isSwitchOn = roomInfo.isOpenCamera
        openCameraItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.roomInfo.isOpenCamera = view.isOn
        }
        switchViewItems.append(openCameraItem)
    }
    
    func enterButtonClick(sender: UIButton, view: CreateRoomView) {
        view.enterButton.isEnabled = false
        view.loading.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            view.enterButton.isEnabled = true
            view.loading.stopAnimating()
        })
        roomInfo.roomId = roomId
        roomInfo.name = currentUser.userName + .videoConferenceText
        roomInfo.speechMode = engineManager.store.roomSpeechMode
        TUIRoomKit.sharedInstance.banAutoRaiseUiOnce(isBan: false)
        TUIRoomKit.sharedInstance.createRoom(roomInfo: roomInfo, type: .meeting)
    }
    
    func switchRoomTypeClick() {
        responder?.showSpeechModeControlView()
    }
    
    func cancelAction(sender: UIButton, view: RoomTypeView) {
        sender.isSelected = !sender.isSelected
        speechMode = engineManager.store.roomSpeechMode
        view.raiseHandButton.isSelected = false
        view.freedomButton.isSelected = false
        view.isHidden = true
    }
    
    func sureAction(sender: UIButton, view: RoomTypeView) {
        sender.isSelected = !sender.isSelected
        engineManager.store.roomSpeechMode = speechMode
        view.isHidden = true
        guard let itemData = inputViewItems.first(where: { $0.titleText == .roomTypeText }) else { return }
        switch engineManager.store.roomSpeechMode {
        case .freeToSpeak:
            itemData.messageText = .freedomSpeakText
        case .applySpeakAfterTakingSeat:
            itemData.messageText = .raiseHandSpeakText
        default: break
        }
        responder?.updateInputStackView(item: itemData, index: 0)
    }
    
    func freedomAction(sender: UIButton, view: RoomTypeView) {
        sender.isSelected = !sender.isSelected
        view.raiseHandButton.isSelected = false
        speechMode = .freeToSpeak
    }
    
    func raiseHandAction(sender: UIButton, view: RoomTypeView) {
        sender.isSelected = !sender.isSelected
        view.freedomButton.isSelected = false
        speechMode = .applySpeakAfterTakingSeat
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var userNameText: String {
        localized("TUIRoom.user.name")
    }
    static var roomTypeText: String {
        localized("TUIRoom.room.type")
    }
    static var roomNumText: String {
        localized("TUIRoom.room.num")
    }
    static var openCameraText: String {
        localized("TUIRoom.open.video")
    }
    static var openMicText: String {
        localized("TUIRoom.open.mic")
    }
    static var openSpeakerText: String {
        localized("TUIRoom.open.speaker")
    }
    static var freedomSpeakText: String {
        localized("TUIRoom.freedom.speaker")
    }
    static var raiseHandSpeakText: String {
        localized("TUIRoom.raise.speaker")
    }
    static var videoConferenceText: String {
        localized("TUIRoom.video.conference")
    }
}
