//
//  ConferenceInvitationEffects.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/12.
//

import Foundation
import RTCRoomEngine
import Combine
import Factory

class ConferenceInvitationEffects: Effects {
    typealias Environment = ServiceCenter
    
    let inviteUsers = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceInvitationActions.inviteUsers)
            .flatMap { action in
                environment.conferenceInvitationService.inviteUsers(roomId: action.payload.0, userIdList: action.payload.1)
                    .map { _ in
                        ConferenceInvitationActions.onInviteSuccess()
                    }
                    .catch { error -> Just<Action> in
                        Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let accept = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceInvitationActions.accept)
            .flatMap { action in
                environment.conferenceInvitationService.accept(roomId: action.payload)
                    .map { roomId in
                        ConferenceInvitationActions.onAcceptSuccess(payload: roomId)
                    }
                    .catch { error -> Just<Action> in
                        environment.store?.dispatch(action: InvitationViewActions.dismissInvitationView())
                        return Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let reject = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceInvitationActions.reject)
            .flatMap { action in
                environment.conferenceInvitationService.reject(roomId: action.payload.0, reason: action.payload.1)
                    .map { _ in
                        ConferenceInvitationActions.onRejectSuccess()
                    }
                    .catch { error -> Just<Action> in
                        Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let getInvitationList = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceInvitationActions.getInvitationList)
            .flatMap { action in
                environment.conferenceInvitationService.getInvitationList(roomId: action.payload.0, cursor: action.payload.1)
                    .map { invitations, cursor in
                        var invitationList = action.payload.2
                        let newList = invitationList + invitations
                        if cursor.isEmpty {
                            return ConferenceInvitationActions.onGetInvitationSuccess(payload: (action.payload.0, newList))
                        } else {
                            return ConferenceInvitationActions.getInvitationList(payload: (action.payload.0, cursor, newList))
                        }
                    }
                    .catch { error -> Just<Action> in
                        Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let fetchAttendees = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceInvitationActions.fetchAttendees)
            .flatMap { action in
                environment.conferenceListService.fetchAttendeeList(conferenceId: action.payload.0, cursor: action.payload.1)
                    .map { userInfoList, cursor, totalCount in
                        var attendeesList = action.payload.2
                        attendeesList.append(contentsOf: userInfoList)
                        if cursor.isEmpty {
                            return ConferenceInvitationActions.onFetchAttendeesSuccess(payload: attendeesList)
                        } else {
                            return ConferenceInvitationActions.fetchAttendees(payload:(action.payload.0, cursor, attendeesList))
                        }
                    }
                    .catch { error -> Just<Action> in
                        Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let onAcceptSuccess = Effect<Environment>.nonDispatching { actions, environment in
        actions
            .wasCreated(from: ConferenceInvitationActions.onAcceptSuccess)
            .sink { action in
                let roomId = action.payload
                InvitationObserverService.shared.dismissInvitationWindow()
                let joinParams = JoinConferenceParams(roomId: roomId)
                joinParams.isOpenMicrophone = true
                joinParams.isOpenCamera = false
                joinParams.isOpenSpeaker = true
                let vc = ConferenceMainViewController()
                vc.setJoinConferenceParams(params: joinParams)
                DispatchQueue.main.async {
                    RoomRouter.shared.push(viewController: vc)
                }
                environment.store?.dispatch(action: InvitationViewActions.dismissInvitationView())
            }
    }
    
    let onReceiveInvitation = Effect<Environment>.nonDispatching { actions, environment in
        actions
            .wasCreated(from: ConferenceInvitationActions.onReceiveInvitation)
            .sink { action in
                let roomInfo = action.payload.0
                let invitation = action.payload.1
                let isEnteredRoom = environment.store?.selectCurrent(RoomSelectors.getIsEnteredRoom)
                let isNotBeingInviting = environment.store?.selectCurrent(ViewSelectors.getDismissInvitationFlag)
                if isEnteredRoom == true {
                    environment.store?.dispatch(action: ConferenceInvitationActions.reject(payload: (roomInfo.roomId, .inOtherConference)))
                } else if isNotBeingInviting == false {
                    environment.store?.dispatch(action: ConferenceInvitationActions.reject(payload: (roomInfo.roomId, .rejectToEnter)))
                } else {
                    InvitationObserverService.shared.showInvitationWindow(roomInfo: roomInfo, invitation: invitation)
                }
            }
    }
    
    let onGetInvitationSuccess = Effect<Environment>.nonDispatching { actions, environment in
        actions
            .wasCreated(from: ConferenceInvitationActions.onGetInvitationSuccess)
            .sink { action in
                let roomId = action.payload.0
                let invitations = action.payload.1
                environment.store?.dispatch(action: ConferenceInvitationActions.updateInvitationList(payload: invitations))
                environment.store?.dispatch(action: ConferenceInvitationActions.fetchAttendees(payload: (roomId, "", [])))
            }
    }
    
    let onFetchAttendeesSuccess = Effect<Environment>.nonDispatching { actions, environment in
        actions
            .wasCreated(from: ConferenceInvitationActions.onFetchAttendeesSuccess)
            .sink { action in
                let attendeeList = action.payload
                var filteredList: [UserInfo] = []
                if let allUsers = environment.store?.selectCurrent(UserSelectors.getAllUsers) {
                    filteredList = attendeeList.filter { user in
                        !allUsers.contains { existedUser in
                            user.userId == existedUser.userId
                        }
                    }
                }
                let resultList = filteredList.map{ TUIInvitation(userInfo: $0) }
                environment.store?.dispatch(action: ConferenceInvitationActions.updateInvitationList(payload: resultList))
            }
    }
}
