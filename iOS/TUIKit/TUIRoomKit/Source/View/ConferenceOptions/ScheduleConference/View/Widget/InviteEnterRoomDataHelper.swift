//
//  InviteEnterRoomDataHelper.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/7/5.
//

import Foundation
import Factory

class InviteEnterRoomDataHelper {
    class func generateInviteEnterRoomHelperData(conferenceInfo: ConferenceInfo, operation: ConferenceStore) -> [ListCellItemData] {
        var array: [ListCellItemData] = []
        array.append(getRoomNameItem(conferenceInfo: conferenceInfo))
        array.append(getRoomTypeItem(conferenceInfo: conferenceInfo))
        array.append(getRoomDurationItem(conferenceInfo: conferenceInfo))
        array.append(getRoomIdItem(conferenceInfo: conferenceInfo, operation: operation))
        if let passwordItem = getRoomPasswordItem(conferenceInfo: conferenceInfo, operation: operation) {
            array.append(passwordItem)
        }
        return array
    }
    
    private class func getRoomNameItem(conferenceInfo: ConferenceInfo) -> ListCellItemData {
        let roomNameItem = getListCellItem(title: .roomName, message: conferenceInfo.basicInfo.name, hasRightButton: false)
        return roomNameItem
    }
    
    private class func getRoomTypeItem(conferenceInfo: ConferenceInfo) -> ListCellItemData {
        let message: String = conferenceInfo.basicInfo.isSeatEnabled ? .onStageSpeechRoom : .freeSpeechRoom
        let roomNameItem = getListCellItem(title: .roomType, message: message, hasRightButton: false)
        return roomNameItem
    }
    
    private class func getRoomDurationItem(conferenceInfo: ConferenceInfo) -> ListCellItemData {
        let scheduleStartTime = getTimeIntervalString(TimeInterval(conferenceInfo.scheduleStartTime), dateFormat: "MM-dd HH:mm")
        let scheduleEndTime = getTimeIntervalString(TimeInterval(conferenceInfo.scheduleEndTime), dateFormat: "HH:mm")
        let nextDayText = isTimeInNextDay(conferenceInfo: conferenceInfo) ? .nextDay : ""
        let message = scheduleStartTime + "-" + nextDayText + scheduleEndTime
        let roomNameItem = getListCellItem(title: .roomDuration, message: message, hasRightButton: false)
        return roomNameItem
    }
    
    private class func isTimeInNextDay(conferenceInfo: ConferenceInfo) -> Bool {
        let startDate = Date(timeIntervalSince1970: TimeInterval(conferenceInfo.scheduleStartTime))
        let endDate = Date(timeIntervalSince1970: TimeInterval(conferenceInfo.scheduleEndTime))
        let calendar = Calendar.current
        let startDay = calendar.dateComponents([.year, .month, .day], from: startDate).day ?? 0
        let endDay = calendar.dateComponents([.year, .month, .day], from: endDate).day ?? 0
        return endDay - startDay == 1
    }
    
    private class func getTimeIntervalString(_ time: TimeInterval, dateFormat: String) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    private class func getRoomIdItem(conferenceInfo: ConferenceInfo, operation: ConferenceStore) -> ListCellItemData {
        let roomIdItem = getListCellItem(title: .roomIdText, message: conferenceInfo.basicInfo.roomId, hasRightButton: true)
        roomIdItem.buttonData?.action = { _ in
            UIPasteboard.general.string = conferenceInfo.basicInfo.roomId
            operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .copyRoomIdSuccess)))
        }
        return roomIdItem
    }
    
    private class func getRoomPasswordItem(conferenceInfo: ConferenceInfo, operation: ConferenceStore) -> ListCellItemData? {
        let password = conferenceInfo.basicInfo.password
        guard password.count > 0 else { return nil }
        let passwordItem = getListCellItem(title: .conferencePasswordText, message: password, hasRightButton: true)
        passwordItem.buttonData?.action = { _ in
            UIPasteboard.general.string = password
            operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .conferencePasswordSuccess)))
        }
        return passwordItem
    }
    
    private class func getRoomLinkItem(roomId: String, operation: ConferenceStore) -> ListCellItemData? {
        guard let roomLink = getRoomLink(roomId: roomId) else { return nil }
        let roomLinkItem = getListCellItem(title: .roomLinkText, message: roomLink, hasRightButton: true)
        roomLinkItem.buttonData?.action = { _ in
            UIPasteboard.general.string = roomLink
            operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .copyRoomLinkSuccess)))
        }
        return roomLinkItem
    }
    
    private class func getListCellItem(title: String, message: String, hasRightButton: Bool) -> ListCellItemData {
        let item = ListCellItemData()
        item.titleText = title
        item.messageText = message
        item.hasRightButton = hasRightButton
        if hasRightButton {
            item.buttonData = getCopyButtonItem()
        }
        item.titleColor = UIColor(0x8F9AB2)
        item.messageColor = UIColor(0x4F586B)
        item.backgroundColor = .clear
        return item
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
    static let conferencePasswordText = localized("Conference password")
    static let conferencePasswordSuccess = localized("Conference password copied successfully.")
    static let roomName = localized("Room name")
    static let roomType = localized("Room type")
    static let roomDuration = localized("Room duration")
    static let freeSpeechRoom = localized("Free Speech Room")
    static let onStageSpeechRoom = localized("On-stage Speech Room")
    static let nextDay = localized("Next Day")
}
