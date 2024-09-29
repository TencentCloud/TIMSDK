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
    case copyRoomPassword
}

protocol RoomInfoResponder : NSObjectProtocol {
    func showCopyToast(copyType: CopyType?)
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
    lazy var title = {
        roomInfo.name
    }()
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
    private lazy var conferenceDetails = {
        title
    }()
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
                                hasButton: Bool, copyType: CopyType?) -> ListCellItemData {
        let item = ListCellItemData()
        item.titleText = titleText
        item.messageText = messageText
        item.hasRightButton = hasButton
        if item.hasRightButton {
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
        }
        conferenceDetails = conferenceDetails +  "\n\(titleText) : \(messageText)"
        return item
    }
    
    func createSourceData() {
        var userName = roomInfo.ownerId
        if let userModel = store.attendeeList.first(where: { $0.userId == roomInfo.ownerId}) {
            userName = userModel.userName
        }
        let roomHostItem = createListCellItemData(titleText: .roomHostText, messageText: userName, hasButton: false, copyType: nil)
        messageItems.append(roomHostItem)
        let roomTypeItem = createListCellItemData(titleText: .roomTypeText, messageText: roomInfo.isSeatEnabled ?  .raiseHandSpeakText: .freedomSpeakText, hasButton: false, copyType: nil)
        messageItems.append(roomTypeItem)
        let roomIdItem = createListCellItemData(titleText: .roomIdText, messageText: roomInfo.roomId, hasButton: true, copyType: .copyRoomIdType)
        messageItems.append(roomIdItem)
        if roomInfo.password.count > 0 {
            let passwordItem = createListCellItemData(titleText: .conferencePasswordText, messageText: roomInfo.password, hasButton: true, copyType: .copyRoomPassword)
            messageItems.append(passwordItem)
        }
        if let roomLink = roomLink {
            let roomLinkItem = createListCellItemData(titleText: .roomLinkText, messageText: roomLink, hasButton: true, copyType: .copyRoomLinkType)
            messageItems.append(roomLinkItem)
        }
    }
    
    func copyAction(sender: UIButton, text: String, copyType: CopyType?){
        UIPasteboard.general.string = text
        viewResponder?.showCopyToast(copyType: copyType)
    }
    
    func codeAction(sender: UIButton) {
        RoomRouter.shared.presentPopUpViewController(viewType: .QRCodeViewType, height: 720.scale375Height())
    }
    
    func copyConferenceDetails() {
        UIPasteboard.general.string = conferenceDetails
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
    static let conferencePasswordText = localized("Conference password")
}
