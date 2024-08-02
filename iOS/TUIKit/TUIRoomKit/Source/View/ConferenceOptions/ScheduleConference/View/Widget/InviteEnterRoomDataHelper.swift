//
//  InviteEnterRoomDataHelper.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/7/5.
//

import Foundation
import Factory

class InviteEnterRoomDataHelper {
    class func generateInviteEnterRoomHelperData(roomId: String, operation: ConferenceStore) -> [ListCellItemData] {
        var array: [ListCellItemData] = []
        array.append(getRoomIdItem(roomId: roomId, operation: operation))
        return array
    }
    
    private class func getRoomIdItem(roomId: String, operation: ConferenceStore) -> ListCellItemData {
        let roomIdItem = ListCellItemData()
        roomIdItem.titleText = .roomIdText
        roomIdItem.messageText = roomId
        roomIdItem.hasRightButton = true
        roomIdItem.buttonData = getCopyButtonItem()
        roomIdItem.titleColor = UIColor(0x8F9AB2)
        roomIdItem.messageColor = UIColor(0x4F586B)
        roomIdItem.backgroundColor = .clear
        roomIdItem.buttonData?.action = { _ in
            UIPasteboard.general.string = roomId
            operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .copyRoomIdSuccess)))
        }
        return roomIdItem
    }
    
    private class func getRoomLinkItem(roomId: String, operation: ConferenceStore) -> ListCellItemData? {
        guard let roomLink = getRoomLink(roomId: roomId) else { return nil }
        let roomLinkItem = ListCellItemData()
        roomLinkItem.titleText = .roomLinkText
        roomLinkItem.messageText = roomLink
        roomLinkItem.hasRightButton = true
        roomLinkItem.titleColor = UIColor(0x8F9AB2)
        roomLinkItem.messageColor = UIColor(0x4F586B)
        roomLinkItem.buttonData = getCopyButtonItem()
        roomLinkItem.backgroundColor = .clear
        roomLinkItem.buttonData?.action = { _ in
            UIPasteboard.general.string = roomLink
            operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .copyRoomLinkSuccess)))
        }
        return roomLinkItem
    }
    
    private class func getCopyButtonItem() -> ButtonItemData {
        let buttonData = ButtonItemData()
        buttonData.normalIcon = "room_copy"
        buttonData.normalTitle = .copyText
        buttonData.cornerRadius = 4
        buttonData.titleFont = UIFont(name: "PingFangSC-Regular", size: 12)
        buttonData.titleColor = UIColor(0x4F586B)
        buttonData.backgroundColor = UIColor(0xD5E0F2).withAlphaComponent(0.7)
        buttonData.resourceBundle = tuiRoomKitBundle()
        return buttonData
    }
    
    private class func getRoomLink(roomId: String) -> String? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        if bundleId == "com.tencent.tuiroom.apiexample" || bundleId == "com.tencent.fx.rtmpdemo" {
            return "https://web.sdk.qcloud.com/trtc/webrtc/test/tuiroom-inner/index.html#/" + "room?roomId=" + roomId
        } else if bundleId == "com.tencent.mrtc" {
            return "https://web.sdk.qcloud.com/component/tuiroom/index.html#/" + "room?roomId=" + roomId
        } else {
            return nil
        }
    }
    
    @Injected(\.conferenceStore) private var operation
}

private extension String {
    static var roomIdText: String {
        localized("Room ID")
    }
    static var roomLinkText: String {
        localized("Room link")
    }
    static var copyText: String {
        localized("Copy")
    }
    static var copyRoomIdSuccess: String {
        localized("Conference ID copied.")
    }
    static var copyRoomLinkSuccess: String {
        localized("Conference Link copied.")
    }
}
