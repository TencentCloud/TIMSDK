//
//  RoomInfoViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/3.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation

class RoomInfoViewModel {
    private(set) var messageItems: [ListCellItemData] = []
    
    init() {
        createSourceData()
    }
    
    func createSourceData() {
        let roomHostItem = ListCellItemData()
        roomHostItem.titleText = .roomHostText
        var userName = EngineManager.shared.store.roomInfo.ownerId
        if let userModel = EngineManager.shared.store.attendeeList.first(where: { $0.userId == EngineManager.shared.store.roomInfo.ownerId}) {
            userName = userModel.userName
        }
        roomHostItem.messageText = userName
        messageItems.append(roomHostItem)
        
        let roomTypeItem = ListCellItemData()
        roomTypeItem.titleText = .roomTypeText
        switch EngineManager.shared.store.roomInfo.speechMode {
        case .freeToSpeak:
            roomTypeItem.messageText = .freedomSpeakText
        case .applySpeakAfterTakingSeat:
            roomTypeItem.messageText = .raiseHandSpeakText
        default: break
        }
        messageItems.append(roomTypeItem)
        
        let roomIdItem = ListCellItemData()
        roomIdItem.titleText = .roomIdText
        roomIdItem.messageText = EngineManager.shared.store.roomInfo.roomId
        roomIdItem.hasButton = true
        roomIdItem.normalIcon = "room_copy"
        roomIdItem.resourceBundle = tuiRoomKitBundle()
        roomIdItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.copyAction(sender: button, text: roomIdItem.messageText)
        }
        messageItems.append(roomIdItem)
        
        let roomLinkItem = ListCellItemData()
        roomLinkItem.titleText = .roomLinkText
        roomLinkItem.messageText = "https://web.sdk.qcloud.com/component/tuiroom/index.html#/" + "room?roomId=" +
        EngineManager.shared.store.roomInfo.roomId
        roomLinkItem.hasButton = true
        roomLinkItem.normalIcon = "room_copy"
        roomLinkItem.resourceBundle = tuiRoomKitBundle()
        roomLinkItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.copyAction(sender: button, text: roomLinkItem.messageText)
        }
        messageItems.append(roomLinkItem)
    }
    
    func copyAction(sender: UIButton, text: String) {
        UIPasteboard.general.string = text
    }
    
    func codeAction(sender: UIButton) {
        RoomRouter.shared.dismissPopupViewController(viewType: .roomInfoViewType)
        RoomRouter.shared.presentPopUpViewController(viewType: .QRCodeViewType, height: nil)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var freedomSpeakText: String {
        localized("TUIRoom.freedom.speaker")
    }
    static var raiseHandSpeakText: String {
        localized("TUIRoom.raise.speaker")
    }
    static var roomHostText: String {
        localized("TUIRoom.host")
    }
    static var roomTypeText: String {
        localized("TUIRoom.room.type")
    }
    static var roomIdText: String {
        localized("TUIRoom.room.num")
    }
    static var roomLinkText: String {
        localized("TUIRoom.room.link")
    }
}
