//
//  RoomInfoViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/3.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUIRoomEngine

enum CopyType {
    case copyRoomIdType
    case copyRoomLinkType
}

protocol RoomInfoResponder : NSObjectProtocol {
    func showCopyToast(copyType: CopyType)
}

class RoomInfoViewModel {
    private(set) var messageItems: [ListCellItemData] = []
    var store: RoomStore {
        EngineManager.createInstance().store
    }
    var roomInfo: TUIRoomInfo {
        store.roomInfo
    }
    weak var viewResponder: RoomInfoResponder?
    //房间链接
    var roomLink: String? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        if bundleId == "com.tencent.tuiroom.apiexample" || bundleId == "com.tencent.fx.rtmpdemo" {
            return "https://web.sdk.qcloud.com/trtc/webrtc/test/tuiroom-inner/index.html#/" + "room?roomId=" + roomInfo.roomId
        } else if bundleId == "com.tencent.mrtc" {
            return "https://web.sdk.qcloud.com/component/tuiroom/index.html#/" + "room?roomId=" + roomInfo.roomId
        } else {
            return nil
        }
    }
    init() {
        createSourceData()
    }
    
    func createListCellItemData(titleText: String, messageText: String,
                                hasButton: Bool, copyType: CopyType) -> ListCellItemData {
        let item = ListCellItemData()
        item.titleText = titleText
        item.messageText = messageText
        item.hasRightButton = true
        let buttonData = ButtonItemData()
        buttonData.normalIcon = "room_copy"
        buttonData.normalTitle = .copyText
        buttonData.cornerRadius = 4
        buttonData.titleFont = UIFont(name: "PingFangSC-Regular", size: 12)
        buttonData.titleColor = UIColor(0xB2BBD1)
        buttonData.backgroundColor = UIColor(0x6B758A).withAlphaComponent(0.7)
        buttonData.resourceBundle = tuiRoomKitBundle()
        buttonData.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.copyAction(sender: button, text: item.messageText,copyType: copyType)
            
        }
        item.buttonData = buttonData
        return item
    }
    
    func createSourceData() {
        let roomHostItem = ListCellItemData()
        roomHostItem.titleText = .roomHostText
        var userName = roomInfo.ownerId
        if let userModel = store.attendeeList.first(where: { $0.userId == roomInfo.ownerId}) {
            userName = userModel.userName
        }
        roomHostItem.messageText = userName
        messageItems.append(roomHostItem)
        
        let roomTypeItem = ListCellItemData()
        roomTypeItem.titleText = .roomTypeText
        roomTypeItem.messageText = roomInfo.isSeatEnabled ?  .raiseHandSpeakText: .freedomSpeakText
        messageItems.append(roomTypeItem)
        
        let roomIdItem = createListCellItemData(titleText: .roomIdText, messageText: roomInfo.roomId, hasButton: true, copyType: .copyRoomIdType)
        messageItems.append(roomIdItem)
        
        if let roomLink = roomLink {
            let roomLinkItem = createListCellItemData(titleText: .roomLinkText, messageText: roomLink, hasButton: true, copyType: .copyRoomLinkType)
            messageItems.append(roomLinkItem)
        }
    }
    
    func copyAction(sender: UIButton, text: String, copyType: CopyType){
        UIPasteboard.general.string = text
        viewResponder?.showCopyToast(copyType: copyType)
    }
    
    func codeAction(sender: UIButton) {
        RoomRouter.shared.dismissPopupViewController(viewType: .roomInfoViewType)
        RoomRouter.shared.presentPopUpViewController(viewType: .QRCodeViewType, height: 720.scale375Height())
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
    static var copyText: String {
        localized("TUIRoom.room.copy")
    }
}
