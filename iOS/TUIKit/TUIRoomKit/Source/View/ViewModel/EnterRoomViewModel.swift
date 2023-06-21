//
//  EnterRoomViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/9.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class EnterRoomViewModel: NSObject {
    private var fieldText: String = ""
    private(set) var inputViewItems: [ListCellItemData] = []
    private(set) var switchViewItems: [ListCellItemData] = []
    var engineManager: EngineManager {
        EngineManager.shared
    }
    var currentUser: UserModel {
        engineManager.store.currentLoginUser
    }
    var roomInfo: RoomInfo {
        engineManager.store.roomInfo
    }
    
    override init() {
        super.init()
        creatEntranceViewModel()
    }
    
    func creatEntranceViewModel() {
        let enterRoomIdItem = ListCellItemData()
        enterRoomIdItem.titleText = .roomNumText
        enterRoomIdItem.fieldEnable = true
        enterRoomIdItem.hasFieldView = true
        enterRoomIdItem.fieldPlaceholderText = .placeholderTipsText
        enterRoomIdItem.action = { [weak self] sender in
            guard let self = self, let view = sender as? UITextField else { return }
            self.fieldText = view.text ?? ""
        }
        inputViewItems.append(enterRoomIdItem)
        
        let userNameItem = ListCellItemData()
        userNameItem.titleText = .userNameText
        userNameItem.messageText = currentUser.userName
        inputViewItems.append(userNameItem)
        
        let openMicItem = ListCellItemData()
        openMicItem.titleText = .openMicText
        openMicItem.hasSwitch = true
        openMicItem.isSwitchOn = roomInfo.isOpenMicrophone
        openMicItem.action = {[weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.roomInfo.isOpenMicrophone = view.isOn
        }
        switchViewItems.append(openMicItem)
        
        let openSpeakerItem = ListCellItemData()
        openSpeakerItem.titleText = .openSpeakerText
        openSpeakerItem.hasSwitch = true
        openSpeakerItem.isSwitchOn = roomInfo.isUseSpeaker
        openSpeakerItem.action = {[weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.roomInfo.isUseSpeaker = view.isOn
        }
        switchViewItems.append(openSpeakerItem)
        
        let openCameraItem = ListCellItemData()
        openCameraItem.titleText = .openCameraText
        openCameraItem.hasSwitch = true
        openCameraItem.isSwitchOn = roomInfo.isOpenCamera
        openCameraItem.action = {[weak self] sender in
            guard let self = self, let view = sender as? UISwitch else { return }
            self.roomInfo.isOpenCamera = view.isOn
        }
        switchViewItems.append(openCameraItem)
    }
    
    func backButtonClick(sender: UIButton) {
        RoomRouter.shared.pop()
    }
    
    func enterButtonClick(sender: UIButton, view: EnterRoomView) {
        view.enterButton.isEnabled = false
        view.loading.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now()+3, execute: {
            view.enterButton.isEnabled = true
            view.loading.stopAnimating()
        })
        if fieldText.count <= 0 {
            view.makeToast(.enterRoomIdErrorToast)
            return
        }
        let roomIDStr = fieldText
            .replacingOccurrences(of: " ",
                                  with: "",
                                  options: .literal,
                                  range: nil)
        if roomIDStr.count <= 0 {
            view.makeToast(.enterRoomIdErrorToast)
            return
        }
        roomInfo.roomId = roomIDStr
        TUIRoomKit.sharedInstance.enterRoom(roomInfo: roomInfo)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var enterRoomIdErrorToast: String {
        localized("TUIRoom.input.error.room.num.toast")
    }
    static var placeholderTipsText: String {
        localized("TUIRoom.input.room.num")
    }
    static var userNameText: String {
        localized("TUIRoom.user.name")
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
}
