//
//  ScheduleConferenceStore.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/27.
//

import Combine

protocol ScheduleConferenceStore {
    func fetchAttendees(cursor: String)
    func update(conference info: ConferenceInfo)
    func select<Value:Equatable>(_ selector: Selector<ConferenceInfo, Value>) -> AnyPublisher<Value, Never>
    var conferenceInfo: ConferenceInfo { get }
}

class ScheduleConferenceStoreProvider {
    static let updateConferenceInfo = ActionTemplate(id: "updateConferenceInfo", payloadType: ConferenceInfo.self)
    static let fetchAttendeeList = ActionTemplate(id: "fetchAttendeeList", payloadType: (String, String, Int).self)
    static let updateAttendeeList = ActionTemplate(id: "updateAttendeeList", payloadType: ([UserInfo], String, UInt).self)
    static let attendeesPerFetch = 20
    
    // MARK: - private property.
    private lazy var store: Store<ConferenceInfo, ServiceCenter> = {
        let store = Store.init(initialState: ConferenceInfo(), environment: ServiceCenter(), reducers: [self.conferenceReducer])
        store.register(effects: scheduleConferenceEffects())
        return store
    }()
    
    private let conferenceReducer = Reducer<ConferenceInfo>(
        ReduceOn(updateConferenceInfo, reduce: { state, action in
            state = action.payload
        }),
        ReduceOn(updateAttendeeList, reduce: { state, action in
            state.attendeeListResult.attendeeList.append(contentsOf: action.payload.0)
            state.attendeeListResult.fetchCursor = action.payload.1
            state.attendeeListResult.totalCount = action.payload.2
        })
    )
    
    deinit {
        store.unregister(reducer: conferenceReducer)
        store.unregisterEffects(withId: scheduleConferenceEffects.id)
    }
}

extension ScheduleConferenceStoreProvider: ScheduleConferenceStore {
    func fetchAttendees(cursor: String) {
        let conferenceId = conferenceInfo.basicInfo.roomId
        store.dispatch(action: ScheduleConferenceStoreProvider.fetchAttendeeList(payload: (conferenceId, cursor, ScheduleConferenceStoreProvider.attendeesPerFetch)))
    }
    
    func update(conference info: ConferenceInfo) {
        store.dispatch(action: ScheduleConferenceStoreProvider.updateConferenceInfo(payload: info))
    }
    
    func select<Value>(_ selector: Selector<ConferenceInfo, Value>) -> AnyPublisher<Value, Never> where Value : Equatable {
        return store.select(selector)
    }
    
    var conferenceInfo: ConferenceInfo {
        return store.state
    }
}

class scheduleConferenceEffects: Effects {
    typealias Environment = ServiceCenter
    
    let fetchAttendeeList = Effect<Environment>.dispatchingOne { actions, environment in
        actions.wasCreated(from: ScheduleConferenceStoreProvider.fetchAttendeeList)
            .flatMap { action in
                environment.conferenceListService.fetchAttendeeList(conferenceId: action.payload.0,
                                                                          cursor: action.payload.1,
                                                                           count: action.payload.2)
                .map { (userInfoList, cursor, totalCount) in
                    ScheduleConferenceStoreProvider.updateAttendeeList(payload: (userInfoList, cursor, totalCount))
                }
                .catch { error -> Just<Action> in
                    Just(ErrorActions.throwError(payload: error))
                }
            }
            .eraseToAnyPublisher()
    }
}
