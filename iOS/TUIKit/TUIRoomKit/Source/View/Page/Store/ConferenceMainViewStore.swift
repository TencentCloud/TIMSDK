//
//  ConferenceMainViewStore.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/9/3.
//

import Foundation
import Combine

protocol ConferenceMainViewStore {
    var isInternalCreation: Bool { get }
    func updateInternalCreation(isInternalCreation: Bool)
    func dispatch(action: Action)
    func select<Value: Equatable>(_ selector: Selector<ConferenceMainViewState, Value>) -> AnyPublisher<Value, Never>
    func selectCurrent<Value>(_ selector: Selector<ConferenceMainViewState, Value>) -> Value
}

class ConferenceMainViewStoreProvider {
    static let updateInternalCreation = ActionTemplate(id: "updateInternalCreation", payloadType: Bool.self)
    private(set) lazy var store: Store<ConferenceMainViewState, Void> = Store(initialState: ConferenceMainViewState())
    private let conferenceMainViewReducer = Reducer<ConferenceMainViewState>(
        ReduceOn(updateInternalCreation) { state,action in
            state.isInternalCreation = action.payload
        }
    )
    
    init() {
        initStore()
    }
    
    deinit {
        store.unregister(reducer: conferenceMainViewReducer)
    }
    
    private func initStore() {
        store.register(reducer: conferenceMainViewReducer)
    }
}

extension ConferenceMainViewStoreProvider: ConferenceMainViewStore {
    var isInternalCreation: Bool {
        return store.state.isInternalCreation
    }
    
    func updateInternalCreation(isInternalCreation: Bool) {
        store.dispatch(action: ConferenceMainViewStoreProvider.updateInternalCreation(payload: isInternalCreation))
    }
    
    func dispatch(action: Action) {
        store.dispatch(action: action)
    }
    
    func select<Value>(_ selector: Selector<ConferenceMainViewState, Value>) -> AnyPublisher<Value, Never> where Value : Equatable {
       return store.select(selector)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func selectCurrent<Value>(_ selector: Selector<ConferenceMainViewState, Value>) -> Value {
       return store.selectCurrent(selector)
    }
}
