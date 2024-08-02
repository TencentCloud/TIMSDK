//
//  MemberInviteViewModel.swift
//  TUIRoomKit
//
//  Created by krabyu on 2023/8/21.
//

import Foundation
import RTCRoomEngine

protocol MemberInviteResponder : NSObjectProtocol {
    func showCopyToast(copyType: CopyType)
}

class MemberInviteViewModel {
    var roomId: String = EngineManager.shared.store.roomInfo.roomId
    var title: String = .inviteMemberText
    private(set) lazy var messageItems: [ListCellItemData] = {
        return generateListData()
    }()
    private var roomLink: String? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        if bundleId == "com.tencent.tuiroom.apiexample" || bundleId == "com.tencent.fx.rtmpdemo" {
            return "https://web.sdk.qcloud.com/trtc/webrtc/test/tuiroom-inner/index.html#/" + "room?roomId=" + roomId
        } else if bundleId == "com.tencent.mrtc" {
            return "https://web.sdk.qcloud.com/component/tuiroom/index.html#/" + "room?roomId=" + roomId
        } else {
            return nil
        }
    }
    weak var viewResponder: MemberInviteResponder?
    
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
    
    func generateListData() -> [ListCellItemData] {
        var array: [ListCellItemData] = []
        let roomIdItem = createListCellItemData(titleText: .roomIdText, messageText: roomId, hasButton: true, copyType: .copyRoomIdType)
        array.append(roomIdItem)
        if let roomLink = roomLink {
            let roomLinkItem = createListCellItemData(titleText: .roomLinkText, messageText: roomLink, hasButton: true, copyType: .copyRoomLinkType)
            array.append(roomLinkItem)
        }
        return array
    }
    
    func copyAction(sender: UIButton, text: String, copyType: CopyType) {
        UIPasteboard.general.string = text
        viewResponder?.showCopyToast(copyType: copyType)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var roomIdText: String {
        localized("ConferenceID")
    }
    static var roomLinkText: String {
        localized("Link")
    }
    static var copyText: String {
        localized("Copy")
    }
    static var inviteMemberText: String {
        localized("Invite member")
    }
}
