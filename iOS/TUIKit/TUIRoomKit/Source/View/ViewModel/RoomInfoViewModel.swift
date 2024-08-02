//
//  RoomInfoViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/3.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import RTCRoomEngine

enum CopyType {
    case copyRoomIdType
    case copyRoomLinkType
}

protocol RoomInfoResponder : NSObjectProtocol {
    func showCopyToast(copyType: CopyType)
    func updateNameLabel(_ text: String)
}

class RoomInfoViewModel: NSObject {
    private(set) var messageItems: [ListCellItemData] = []
    var store: RoomStore {
        EngineManager.shared.store
    }
    var roomInfo: TUIRoomInfo {
        store.roomInfo
    }
    weak var viewResponder: RoomInfoResponder?
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
    override init() {
        super.init()
        subscribeEngine()
        createSourceData()
    }
    
    private func subscribeEngine() {
        EngineEventCenter.shared.subscribeEngine(event: .onConferenceInfoChanged, observer: self)
    }
    
    private func unsubscribeUIEvent() {
        EngineEventCenter.shared.unsubscribeEngine(event: .onConferenceInfoChanged, observer: self)
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
        RoomRouter.shared.presentPopUpViewController(viewType: .QRCodeViewType, height: 720.scale375Height())
    }
    
    deinit {
        unsubscribeUIEvent()
        debugPrint("deinit \(self)")
    }
}

extension RoomInfoViewModel: RoomEngineEventResponder {
    func onEngineEvent(name: EngineEventCenter.RoomEngineEvent, param: [String : Any]?) {
        switch name {
        case .onConferenceInfoChanged:
            guard let conferenceInfo = param?["conferenceInfo"] as? TUIConferenceInfo else { return }
            guard let modifyFlag = param?["modifyFlag"] as? TUIConferenceModifyFlag else { return }
            guard modifyFlag.contains(.roomName) else { return }
            viewResponder?.updateNameLabel(conferenceInfo.basicRoomInfo.name)
        default: break
        }
    }
}

private extension String {
    static var freedomSpeakText: String {
        localized("Free Speech Conference")
    }
    static var raiseHandSpeakText: String {
        localized("On-stage Speaking Conference")
    }
    static var roomHostText: String {
        localized("Host")
    }
    static var roomTypeText: String {
        localized("Conference Type")
    }
    static var roomIdText: String {
        localized("ConferenceID")
    }
    static var roomLinkText: String {
        localized("Link")
    }
    static var copyText: String {
        localized("Copy")
    }
}
