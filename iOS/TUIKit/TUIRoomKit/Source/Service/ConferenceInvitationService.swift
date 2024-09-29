//
//  ConferenceInvitationService.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/8.
//

import Foundation
import RTCRoomEngine
import Combine
import Factory

class ConferenceInvitationService: NSObject {
    @WeakLazyInjected(\.conferenceStore) var store: ConferenceStore?
    
    typealias InviteUsersResult = ([String: NSNumber])
    typealias InvitationfetchResult = ([TUIInvitation], String)
    private let timeout: Double = 60
    private let invitationManager = TUIRoomEngine.sharedInstance().getExtension(extensionType: .conferenceInvitationManager) as? TUIConferenceInvitationManager
    
    override init() {
        super.init()
        invitationManager?.addObserver(self)
    }
    
    deinit {
        invitationManager?.removeObserver(self)
    }
    
    func inviteUsers(roomId: String, userIdList: [String]) -> AnyPublisher<InviteUsersResult, RoomError> {
        return Future<InviteUsersResult, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.invitationManager?.inviteUsers(roomId, userIdList: userIdList, timeout: timeout, extensionInfo: "") {dic in
                promise(.success((dic)))
            } onError: { error, message in
                promise(.failure(RoomError(error: error, message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func accept(roomId: String) -> AnyPublisher<String, RoomError> {
        return Future<String, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.invitationManager?.accept(roomId) {
                promise(.success(roomId))
            } onError: { error, message in
                promise(.failure(RoomError(error: error, message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func reject(roomId: String, reason: TUIInvitationRejectedReason) -> AnyPublisher<String, RoomError> {
        return Future<String, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.invitationManager?.reject(roomId, reason: reason) {
                promise(.success(roomId))
            } onError: { error, message in
                promise(.failure(RoomError(error: error, message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getInvitationList(roomId: String, cursor: String, count: Int = 20) -> AnyPublisher<InvitationfetchResult, RoomError> {
        return Future<InvitationfetchResult, RoomError> { [weak self] promise in
            guard let self = self else { return }
            self.invitationManager?.getInvitationList(roomId, cursor: cursor, count: count) {invitations, cursor in
                promise(.success((invitations, cursor)))
            } onError: { error, message in
                promise(.failure(RoomError(error: error, message: message)))
            }
        }
        .eraseToAnyPublisher()
    }
}

extension ConferenceInvitationService: TUIConferenceInvitationObserver {
    func onReceiveInvitation(roomInfo: TUIRoomInfo, invitation: TUIInvitation, extensionInfo: String) {
        
    }
    
    func onInvitationHandledByOtherDevice(roomInfo: TUIRoomInfo, accepted: Bool) {
        guard let store = self.store else { return }
        store.dispatch(action: InvitationViewActions.dismissInvitationView())
    }
    
    func onInvitationCancelled(roomInfo: TUIRoomInfo, invitation: TUIInvitation) {
        
    }
    
    func onInvitationAccepted(roomInfo: TUIRoomInfo, invitation: TUIInvitation) {
        
    }
    
    func onInvitationRejected(roomInfo: TUIRoomInfo, invitation: TUIInvitation, reason: TUIInvitationRejectedReason) {
        
    }
    
    func onInvitationTimeout(roomInfo: TUIRoomInfo, invitation: TUIInvitation) {
        guard let store = self.store else { return }
        store.dispatch(action: InvitationViewActions.dismissInvitationView())
    }
    
    func onInvitationRevokedByAdmin(roomInfo: TUIRoomInfo, invitation: TUIInvitation, admin: TUIUserInfo) {
        
    }
    
    func onInvitationAdded(roomId: String, invitation: TUIInvitation) {
        guard let store = self.store else { return }
        let currentRoomId = store.selectCurrent(RoomSelectors.getRoomId)
        guard currentRoomId == roomId else { return }
        store.dispatch(action: ConferenceInvitationActions.addInvitation(payload: invitation))
    }
    
    func onInvitationRemoved(roomId: String, invitation: TUIInvitation) {
        guard let store = self.store else { return }
        let currentRoomId = store.selectCurrent(RoomSelectors.getRoomId)
        guard currentRoomId == roomId else { return }
        store.dispatch(action: ConferenceInvitationActions.removeInvitation(payload: invitation.invitee.userId))
    }
    
    func onInvitationStatusChanged(roomId: String, invitation: TUIInvitation) {
        guard let store = self.store else { return }
        let currentRoomId = store.selectCurrent(RoomSelectors.getRoomId)
        guard currentRoomId == roomId else { return }
        store.dispatch(action: ConferenceInvitationActions.changeInvitationStatus(payload: invitation))
    }
    
}
