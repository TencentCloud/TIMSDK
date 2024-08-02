//
//  ConferenceStore.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/12.
//

import Foundation
import Combine

protocol ActionDispatcher {
    func dispatch(action: Action)
}

protocol ConferenceStore: ActionDispatcher {
    var errorSubject: PassthroughSubject<RoomError, Never> { get }
    var toastSubject: PassthroughSubject<ToastInfo, Never> { get }
    var scheduleActionSubject: PassthroughSubject<IdentifiableAction, Never> { get }
    
    func select<Value:Equatable>(_ selector: Selector<OperationState, Value>) -> AnyPublisher<Value, Never>
    
    func selectCurrent<Value>(_ selector: Selector<OperationState, Value>) -> Value
    
    func select<Value:Equatable>(_ selector: Selector<ViewState, Value>) -> AnyPublisher<Value, Never>
    
    func selectCurrent<Value>(_ selector: Selector<ViewState, Value>) -> Value
}
