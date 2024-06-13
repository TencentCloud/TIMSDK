/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

/// A type which intercepts all `Action`s and the  `State` changes happening in a `Store`.
public protocol Interceptor {
    /// The type of `State` the `Interceptor` will get.
    associatedtype State
    /**
     The function called when an `Action` is dispatched on a `Store`.

     - Parameter action: The `Action` dispatched
     - Parameter oldState: The `State` before the `Action` was dispatched
     - Parameter newState: The `State` after the `Action` was dispatched
     */
    func actionDispatched(action: Action, oldState: State, newState: State)
    /// The identifier for the `Interceptor`
    static var id: String { get }
}

public extension Interceptor {
    static var id: String { .init(describing: self) }
}

/// A type-erased `Interceptor` used to store all `Interceptor`s in an array in the `Store`.
internal struct AnyInterceptor<State>: Interceptor {
    let originalId: String
    private let _actionDispatched: (Action, State, State) -> Void

    init<I: Interceptor>(_ interceptor: I) where I.State == State {
        originalId = type(of: interceptor).id
        _actionDispatched = interceptor.actionDispatched
    }

    func actionDispatched(action: Action, oldState: State, newState: State) {
        _actionDispatched(action, oldState, newState)
    }
}
