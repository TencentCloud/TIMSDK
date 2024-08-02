//
//  ConferenceListService.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/27.
//

import Foundation
import RTCRoomEngine
import Combine
import Factory

class ConferenceListService: NSObject {
    @WeakLazyInjected(\.conferenceStore) var store: ConferenceStore?
    
    private let listManager = TUIRoomEngine.sharedInstance().getExtension(extensionType: .conferenceListManager) as? TUIConferenceListManager
    typealias ConferencesFetchResult = ([ConferenceInfo], String)
    typealias AttendeesFetchResult = ([UserInfo], String, UInt)
    
    override init() {
        super.init()
        listManager?.addObserver(self)
    }
    
    deinit {
        listManager?.removeObserver(self)
    }
    
    func scheduleConference(conferenceInfo: TUIConferenceInfo) -> AnyPublisher<String, RoomError> {
        return Future<String, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.listManager?.scheduleConference(conferenceInfo) {
                promise(.success((conferenceInfo.basicRoomInfo.roomId)))
            } onError: { error, message in
                promise(.failure(RoomError(error: error, message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    func cancelConference(conferenceId: String) -> AnyPublisher<Void, RoomError> {
        return Future<Void, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.listManager?.cancelConference(conferenceId) {
                promise(.success(()))
            } onError: { error, message in
                promise(.failure(RoomError(error: error , message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func updateConferenceInfo(conferenceInfo: TUIConferenceInfo, modifyFlag: TUIConferenceModifyFlag) -> AnyPublisher<Void, RoomError> {
        return Future<Void, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.listManager?.updateConferenceInfo(conferenceInfo: conferenceInfo, modifyFlag: modifyFlag) {
                promise(.success(()))
            } onError: { error, message in
                promise(.failure(RoomError(error: error , message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchConferenceList(status: TUIConferenceStatus, cursor: String, count: Int = 20) -> AnyPublisher<ConferencesFetchResult, RoomError> {
        return Future<ConferencesFetchResult, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.listManager?.fetchScheduledConferenceList(status: status,
                                                           cursor: cursor,
                                                           count: count) { conferenceList, cursor in
                let list = conferenceList.map { ConferenceInfo(with: $0) }
                promise(.success((list, cursor)))
            } onError: { error, message in
                promise(.failure(RoomError(error: error, message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchAttendeeList(conferenceId: String, cursor: String, count: Int = 20) -> AnyPublisher<AttendeesFetchResult, RoomError> {
        return Future<AttendeesFetchResult, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.listManager?.fetchAttendeeList(roomId: conferenceId, cursor: cursor, count: count) { attendeeList, cursor, totalCount  in

                let userInfoList = attendeeList.map { UserInfo(userInfo: $0) }
                promise(.success((userInfoList, cursor, totalCount)))
            } onError: { error, message in
                promise(.failure(RoomError(error: error, message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addAttendeesByAdmin(conferenceId: String, userIdList: [String]) -> AnyPublisher<Void, RoomError> {
        return Future<Void, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.listManager?.addAttendeesByAdmin(roomId: conferenceId, userIdList: userIdList) {
                promise(.success(()))
            } onError: { error, message in
                promise(.failure(RoomError(error: error , message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func removeAttendeesByAdmin(conferenceId: String, userIdList: [String]) -> AnyPublisher<Void, RoomError> {
        return Future<Void, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.listManager?.removeAttendeesByAdmin(roomId: conferenceId, userIdList: userIdList) {
                promise(.success(()))
            } onError: { error, message in
                promise(.failure(RoomError(error: error , message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
}

extension ConferenceListService: TUIConferenceListManagerObserver {
    func onConferenceScheduled(conferenceInfo: TUIConferenceInfo) {
        guard let store = self.store else { return }
        let conference = ConferenceInfo(with: conferenceInfo)
        let currentList = store.selectCurrent(ConferenceListSelectors.getConferenceList)
        let contain = currentList.contains { $0.basicInfo.roomId == conference.basicInfo.roomId }
        if !contain {
            store.dispatch(action: ConferenceListActions.insertConference(payload: conference))
        }
    }
    
    func onConferenceCancelled(roomId: String, reason: TUIConferenceCancelReason, operateUser: TUIUserInfo) {
        guard let store = self.store else { return }
        let currentList = store.selectCurrent(ConferenceListSelectors.getConferenceList).map { $0.basicInfo.roomId }
        if currentList.contains(roomId) {
            store.dispatch(action: ConferenceListActions.removeConference(payload: roomId))
        }
    }
    
    func onConferenceInfoChanged(conferenceInfo: TUIConferenceInfo, modifyFlag: TUIConferenceModifyFlag) {
        guard let store = self.store else { return }
        let currentList = store.selectCurrent(ConferenceListSelectors.getConferenceList)
        if let index = currentList.firstIndex(where: { $0.basicInfo.roomId == conferenceInfo.basicRoomInfo.roomId }) {
            var updateConference = currentList[index]
            if modifyFlag.contains(.roomName) {
                updateConference.basicInfo.name = conferenceInfo.basicRoomInfo.name
            }
            if modifyFlag.contains(.scheduleStartTime) || modifyFlag.contains(.scheduleEndTime) {
                updateConference.scheduleStartTime = conferenceInfo.scheduleStartTime
                updateConference.scheduleEndTime = conferenceInfo.scheduleEndTime
                updateConference.durationTime = conferenceInfo.scheduleEndTime - conferenceInfo.scheduleStartTime
            }
            store.dispatch(action: ConferenceListActions.onConferenceUpdated(payload: updateConference))
        }
    }
    
    func onConferenceStatusChanged(roomId: String, status: TUIConferenceStatus) {
        guard let store = self.store else { return }
        let currentList = store.selectCurrent(ConferenceListSelectors.getConferenceList)
        if let index = currentList.firstIndex(where: { $0.basicInfo.roomId == roomId }) {
            var updateConference = currentList[index]
            updateConference.status = status
            store.dispatch(action: ConferenceListActions.onConferenceUpdated(payload: updateConference))
        }
    }
    
    func onConferenceWillStart(conferenceInfo: TUIConferenceInfo) {
        
    }
    
    func onScheduleAttendeesChanged(roomId: String, leftUsers: [TUIUserInfo], joinedUsers: [TUIUserInfo]) {

    }
    
    
}
