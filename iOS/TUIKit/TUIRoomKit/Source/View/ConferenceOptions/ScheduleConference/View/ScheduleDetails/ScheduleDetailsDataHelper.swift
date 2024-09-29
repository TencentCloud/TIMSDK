//
//  ScheduleDetailsDataHelper.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/26.
//

import Foundation
import RTCRoomEngine

class ScheduleDetailsDataHelper: ScheduleConferenceDataHelper {
    
    class func generateScheduleDetailsConferenceData(route: Route, store: ScheduleConferenceStore, operation: ConferenceStore, viewStore: ConferenceMainViewStore) -> [Int : [CellConfigItem]] {
        var menus: [Int:[CellConfigItem]] = [:]
        menus[0] = getFirstSectionDetailsMenus(route: route, store: store, operation: operation)
        menus[1] = getSecondSectionDetailsMenus(store: store, operation: operation, viewStore: viewStore)
        menus[2] = getThirdSectionDetailsMenus(route: route, store: store, operation: operation)
        guard let fourthSectionDetailsMenus = getFourthSectionDetailsMenus(route: route, store: store, operation: operation) else { return menus }
        menus[3] = fourthSectionDetailsMenus
        return menus
    }
    
    private class func getFirstSectionDetailsMenus(route: Route, store: ScheduleConferenceStore, operation: ConferenceStore) -> [CellConfigItem] {
        var array: [CellConfigItem] = []
        array.append(getDetailsConferenceNameItem(route: route, store: store))
        array.append(getDetailsConferenceIdItem(route: route, store: store, operation: operation))
        array.append(getDetailsStartTimeItem(route: route, store: store))
        array.append(getDetailsDurationTimeItem(route: route, store: store))
        array.append(getDetailsConferenceTypeItem(route: route, store: store))
        if let passwordItem = getConferencePasswordItem(store: store) {
            array.append(passwordItem)
        }
        array.append(getRoomHostItem(route: route, store: store))
        array.append(getDetailsParticipatingMembersItem(route: route, store: store))
        return array
    }
    
    private class func getSecondSectionDetailsMenus(store: ScheduleConferenceStore, operation: ConferenceStore, viewStore: ConferenceMainViewStore) -> [CellConfigItem] {
        return [getEnterRoomItem(store: store, operation: operation, viewStore: viewStore)]
    }
    
    private class func getThirdSectionDetailsMenus(route: Route, store: ScheduleConferenceStore, operation: ConferenceStore) -> [CellConfigItem] {
        return [getInviteItem(route: route, store: store)]
    }
    
    private class func getFourthSectionDetailsMenus(route: Route, store: ScheduleConferenceStore, operation: ConferenceStore) -> [CellConfigItem]? {
        guard store.conferenceInfo.basicInfo.ownerId == operation.selectCurrent(UserSelectors.getSelfId) else { return nil }
        guard store.conferenceInfo.status == .notStarted else { return nil }
        return [getCancelRoomItem(route: route, store: store, operation: operation)]
    }
    
    private class func getDetailsConferenceNameItem(route: Route, store: ScheduleConferenceStore) -> TextFieldItem {
        var conferenceNameItem = getConferenceNameItem(route: route, store: store)
        conferenceNameItem.isEnable = false
        return conferenceNameItem
    }
    
    private class func getDetailsConferenceIdItem(route: Route, store: ScheduleConferenceStore, operation: ConferenceStore) -> ListItem {
        var conferenceIdItem = ListItem(title: .roomIDText, content: store.conferenceInfo.basicInfo.roomId)
        conferenceIdItem.showButton = true
        conferenceIdItem.buttonIcon = "room_copy_blue"
        conferenceIdItem.selectClosure = {
            UIPasteboard.general.string = store.conferenceInfo.basicInfo.roomId
            operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .copyRoomIdSuccess)))
        }
        return conferenceIdItem
    }
    
    private class func getDetailsConferenceTypeItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        var conferenceTypeItem = getConferenceTypeItem(route: route, store: store)
        conferenceTypeItem.showButton = false
        conferenceTypeItem.selectClosure = nil
        return conferenceTypeItem
    }
    
    private class func getDetailsStartTimeItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        var startTimeItem = getStartTimeItem(route: route, store: store)
        startTimeItem.selectClosure = nil
        startTimeItem.showButton = false
        return startTimeItem
    }
    
    private class func getDetailsDurationTimeItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        var durationTimeItem = getDurationTimeItem(route: route, store: store)
        durationTimeItem.selectClosure = nil
        durationTimeItem.showButton = false
        return durationTimeItem
    }
    
    private class func getRoomHostItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        var hostItem = ListItem(title: .creatorText, content: store.conferenceInfo.basicInfo.ownerName)
        hostItem.iconList = [store.conferenceInfo.basicInfo.ownerAvatarUrl]
        return hostItem
    }
    
    private class func getDetailsParticipatingMembersItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        var item = getParticipatingMembersItem(route: route, store: store)
        item.buttonIcon = "room_down_arrow1"
        item.selectClosure = {
            if store.conferenceInfo.attendeeListResult.attendeeList.count > 0 {
                route.present(route: .selectedMember(showDeleteButton: false, selectedMembers: store.conferenceInfo.attendeeListResult.attendeeList))
            }
        }
        item.bindStateClosure = {  cell, cancellableSet in
            let selector = Selector(keyPath: \ConferenceInfo.attendeeListResult.attendeeList)
            store.select(selector)
                .receive(on: RunLoop.main)
                .removeDuplicates()
                .sink { list in
                    if let cell = cell as? ScheduleTabCell {
                        var iconList: [String] = []
                        for i in 0...2 {
                            if let userInfo = list[safe: i] {
                                let avatarUrl = userInfo.avatarUrl.count > 0 ? userInfo.avatarUrl : "room_default_avatar_rect"
                                iconList.append(avatarUrl)
                            }
                        }
                        cell.updateStackView(iconList: iconList)
                        let totalCount = store.conferenceInfo.attendeeListResult.totalCount
                        cell.messageLabel.text = totalCount == 0 ? .noParticipantsYet : localizedReplace(.participantsNumber, replace: String(totalCount))
                        cell.updateButton(isShown: list.count > 0)
                    }
                }
                .store(in: &cancellableSet)
        }
        return item
    }
    
    private class func getConferencePasswordItem(store: ScheduleConferenceStore) -> ListItem? {
        guard store.conferenceInfo.basicInfo.password.count > 0 else { return nil }
        var passwordItem = ListItem(title: .conferencePasswordText)
        passwordItem.content = store.conferenceInfo.basicInfo.password
        passwordItem.selectClosure = nil
        passwordItem.showButton = false
        return passwordItem
    }
    
    private class func getEnterRoomItem(store: ScheduleConferenceStore, operation: ConferenceStore, viewStore: ConferenceMainViewStore) -> ButtonItem {
        var item = ButtonItem(title: .enterTheRoomText)
        item.titleColor = UIColor(0x0961F7)
        item.backgroudColor = UIColor(0xF0F3FA)
        item.selectClosure = {
            let conferenceId = store.conferenceInfo.basicInfo.roomId
            operation.dispatch(action: RoomActions.joinConference(payload: conferenceId))
            operation.dispatch(action: ScheduleViewActions.popDetailView())
            viewStore.updateInternalCreation(isInternalCreation: true)
        }
        return item
    }
    
    private class func getInviteItem(route: Route, store: ScheduleConferenceStore) -> ButtonItem {
        var item = ButtonItem(title: .inviteMemberText)
        item.titleColor = UIColor(0x0961F7)
        item.backgroudColor = UIColor(0xF0F3FA)
        item.selectClosure = {
            let view = InviteEnterRoomView(conferenceInfo: store.conferenceInfo)
            route.present(route: .popup(view: view))
        }
        return item
    }
    
    private class func getCancelRoomItem(route: Route, store: ScheduleConferenceStore, operation: ConferenceStore) -> ButtonItem {
        var item = ButtonItem(title: .cancelRoomText)
        item.titleColor = UIColor(0xED414D)
        item.backgroudColor = UIColor(0xFAF0F0)
        item.selectClosure = {
            let declineAction = UIAlertAction(title: .notCanceledYet, style: .cancel)
            declineAction.setValue(UIColor(0x4F586B), forKey: "titleTextColor")
            let sureAction = UIAlertAction(title: .cancelRoom, style: .default) { _ in
                operation.dispatch(action: ConferenceListActions.cancelConference(payload: store.conferenceInfo.basicInfo.roomId))
            }
            sureAction.setValue(UIColor(0xED414D), forKey: "titleTextColor")
            let alertState = AlertState(title: .cancelBookedRoomTitle, message: .cancelBookedRoomMessage, sureAction: sureAction, declineAction: declineAction)
            route.present(route: .alert(state: alertState))
        }
        return item
    }
}

private extension String {
    static let creatorText: String = localized("Creator")
    static let roomIDText: String = localized("Room ID")
    static let enterTheRoomText = localized("Enter the room")
    static let inviteMemberText = localized("Invite member")
    static let cancelRoomText = localized("Cancel Room")
    static let cancelBookedRoomTitle = localized("Cancel this booked room")
    static let cancelBookedRoomMessage = localized("After cancellation, other members will not be able to join")
    static let notCanceledYet = localized("Not canceled yet")
    static let cancelRoom = localized("Cancel Room")
    static let copyRoomIdSuccess = localized("Conference ID copied.")
    static let noParticipantsYet = localized("No participants yet")
    static let participantsNumber = localized("xx/300 people")
    static let conferencePasswordText = localized("Conference password")
}
