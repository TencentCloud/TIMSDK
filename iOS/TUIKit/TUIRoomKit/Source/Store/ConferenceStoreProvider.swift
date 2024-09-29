//
//  ConferenceStoreProvider.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation
import Combine

class ConferenceStoreProvider {
    let errorSubject = PassthroughSubject<RoomError, Never>()
    let toastSubject = PassthroughSubject<ToastInfo, Never>()
    let scheduleActionSubject = PassthroughSubject<any IdentifiableAction, Never>()
    
    private(set) lazy var operation: Store<OperationState, ServiceCenter> = {
        return Store(initialState: OperationState(), environment: ServiceCenter())
    }()
    private(set) lazy var viewStore: Store<ViewState, Void> = Store(initialState: ViewState())
    private var cancellableSet: Set<AnyCancellable> = []
    
    init() {
        initializeStore()
    }
    
    private func initializeStore() {
        initializeUserStore()
        initializeConferenceListStore()
        initializeConferenceInvitationStore()
        initializeRoomStore()
        initializeErrorEffect()
        initializedViewStore()
    }
    
    private func initializeUserStore() {
        operation.register(reducer: userReducer, for: \.userState)
        operation.register(effects: UserEffects())
    }
    
    private func initializeConferenceListStore() {
        operation.register(reducer: ConferenceListReducer, for: \.conferenceListState)
        operation.register(effects: ConferenceListEffects())
    }
    
    private func initializeConferenceInvitationStore() {
        operation.register(reducer: ConferenceInvitationReducer, for: \.conferenceInvitationState)
        operation.register(effects: ConferenceInvitationEffects())
    }
    
    private func initializeRoomStore() {
        operation.register(reducer: roomReducer, for: \.roomState)
        operation.register(effects: RoomEffects())
    }
    
    private func initializeErrorEffect() {
        operation.register(effects: ErrorEffects())
        errorSubject
            .sink { [weak self] error in
                guard let self = self else { return }
                self.handle(error: error)
            }
            .store(in: &cancellableSet)
    }
    
    private func initializedViewStore() {
        viewStore.register(reducer: scheduleViewReducer,for: \ViewState.scheduleViewState)
        viewStore.register(reducer: invitationViewReducer, for: \ViewState.invitationViewState)
    }
    
    deinit {
        operation.unregister(reducer: userReducer)
        operation.unregisterEffects(withId: UserEffects.id)
        
        operation.unregister(reducer: ConferenceListReducer)
        operation.unregisterEffects(withId: ConferenceListEffects.id)
        
        operation.unregister(reducer: ConferenceInvitationReducer)
        operation.unregisterEffects(withId: ConferenceInvitationEffects.id)
        
        operation.unregister(reducer: roomReducer)
        operation.unregisterEffects(withId: RoomEffects.id)
        
        operation.unregisterEffects(withId: ErrorEffects.id)
        
        viewStore.unregister(reducer: scheduleViewReducer)
        viewStore.unregister(reducer: invitationViewReducer)
    }
}

extension ConferenceStoreProvider: ConferenceStore {
    func dispatch(action: Action) {
        guard let action = action as? IdentifiableAction else { return }
        if action.id.hasPrefix(ScheduleResponseActions.key) {
            scheduleActionSubject.send(action)
        }
        
        if action.id.hasPrefix(ViewActions.toastActionKey) {
            handleToast(action: action)
        } else if action.id.hasPrefix(ViewActions.key) {
            viewStore.dispatch(action: action)
        } else {
            operation.dispatch(action: action)
        }
    }
    
    func select<Value: Equatable>(_ selector: Selector<OperationState, Value>) -> AnyPublisher<Value, Never> {
        return operation.select(selector)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func selectCurrent<Value>(_ selector: Selector<OperationState, Value>) -> Value {
        return operation.selectCurrent(selector)
    }
    
    func select<Value:Equatable>(_ selector: Selector<ViewState, Value>) -> AnyPublisher<Value, Never> {
        return viewStore.select(selector)
    }
    
    func selectCurrent<Value>(_ selector: Selector<ViewState, Value>) -> Value {
        return viewStore.selectCurrent(selector)
    }
}

extension ConferenceStoreProvider {
    private func handle(error: RoomError) {
        error.actions.forEach { action in
            guard let action = action as? IdentifiableAction else { return }
            dispatch(action: action)
        }
    }
    
    private func handleToast(action: Action) {
        if let viewAction = action as? AnonymousAction<ToastInfo> {
            toastSubject.send(viewAction.payload)
        }
    }
}
