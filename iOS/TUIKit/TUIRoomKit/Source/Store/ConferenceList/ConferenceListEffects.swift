//
//  ConferenceListEffects.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation
import RTCRoomEngine
import Combine

class ConferenceListEffects: Effects {
    typealias Environment = ServiceCenter
    
    let scheduleConference = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceListActions.scheduleConference)
            .flatMap { action in
                environment.conferenceListService.scheduleConference(conferenceInfo: action.payload)
                    .map { conferenceInfo in
                        ConferenceListActions.onScheduleSuccess(payload: conferenceInfo)
                    }
                    .catch { error -> Just<Action> in
                        Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let cancelConference = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceListActions.cancelConference)
            .flatMap { action in
                environment.conferenceListService.cancelConference(conferenceId: action.payload)
                    .map { _ in
                        ConferenceListActions.onCancelSuccess()
                    }
                    .catch { error -> Just<Action> in
                        Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let updateConferenceInfo = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceListActions.updateConferenceInfo)
            .flatMap { action in
                environment.conferenceListService.updateConferenceInfo(conferenceInfo: action.payload.0,
                                                                           modifyFlag: action.payload.1)
                .map { _ in
                    ConferenceListActions.onUpdateInfoSuccess()
                }
                .catch { error -> Just<Action> in
                    Just(ErrorActions.throwError(payload: error))
                }
            }
            .eraseToAnyPublisher()
    }
    
    let fetchConferenceList = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceListActions.fetchConferenceList)
            .flatMap { action in
                environment.conferenceListService.fetchConferenceList(status: [.notStarted, .running],
                                                                      cursor: action.payload.0,
                                                                       count: action.payload.1)
                .map { (conferenceList, cursor) in
                    ConferenceListActions.updateConferenceList(payload: (conferenceList, cursor))
                }
                .catch { error -> Just<Action> in
                    Just(ErrorActions.throwError(payload: error))
                }
            }
            .eraseToAnyPublisher()
    }
    
    let addAttendeesByAdmin = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceListActions.addAttendeesByAdmin)
            .flatMap { action in
                environment.conferenceListService.addAttendeesByAdmin(conferenceId: action.payload.0, userIdList: action.payload.1)
                    .map { _ in
                        ConferenceListActions.onAddAttendeesSuccess()
                    }
                    .catch { error -> Just<Action> in
                        Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let removeAttendeesByAdmin = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ConferenceListActions.removeAttendeesByAdmin)
            .flatMap { action in
                environment.conferenceListService.removeAttendeesByAdmin(conferenceId: action.payload.0, userIdList: action.payload.1)
                    .map { _ in
                        ConferenceListActions.onRemoveAttendeesSuccess()
                    }
                    .catch { error -> Just<Action> in
                        Just(ErrorActions.throwError(payload: error))
                    }
            }
            .eraseToAnyPublisher()
    }
    
    let onScheduleSuccess = Effect<Environment>.nonDispatching { actions, environment in
        actions
            .wasCreated(from: ConferenceListActions.onScheduleSuccess)
            .sink { action in
                let conferenceInfo = action.payload
                environment.store?.dispatch(action: ScheduleResponseActions.onScheduleSuccess(payload: conferenceInfo))
            }
    }
    
    let onCancelSuccess = Effect<Environment>.nonDispatching { actions, environment in
        actions
            .wasCreated(from: ConferenceListActions.onCancelSuccess)
            .sink { action in
                environment.store?.dispatch(action: ScheduleResponseActions.onCancelSuccess())
            }
    }
    
}

