//
//  ConferenceRoomStore.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/5/10.
//

import Foundation
#if USE_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

class FloatChatStore {
    private(set) lazy var store: Store<FloatChatState, FloatChatService> = Store(initialState: FloatChatState(), environment: FloatChatService())
    
    init() {
        initStore()
    }
    
    deinit {
        store.unregister(reducer: floatChatReducer)
        store.unregisterEffects(withId: FloatChatEffect.id)
    }
    
    private func initStore() {
        store.register(reducer: floatChatReducer)
        store.register(effects: FloatChatEffect())
    }
}

extension FloatChatStore: FloatChatStoreProvider {
    func dispatch(action: Action) {
        store.dispatch(action: action)
    }
    
    func select<Value>(_ selector: Selector<FloatChatState, Value>) -> AnyPublisher<Value, Never> where Value : Equatable {
       return store.select(selector)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func selectCurrent<Value>(_ selector: Selector<FloatChatState, Value>) -> Value {
       return store.selectCurrent(selector)
    }
}






