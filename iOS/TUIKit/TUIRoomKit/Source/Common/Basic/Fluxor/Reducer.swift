/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/// A type which takes a `State` and `Action` returns a new `State`.
public struct Reducer<State> {
    /// An unique identifier used when registering/unregistering the `Reducer` on the `Store`.
    public let id: String
    /// A pure function which takes the a `State` and an `Action` and returns a new `State`.
    public let reduce: (inout State, Action) -> Void

    /**
     Creates a `Reducer` from a `reduce` function.

     The `reduce` function is a pure function which takes the a `State` and an `Action` and returns a new `State`.

     - Parameter reduce: The `reduce` function to create a `Reducer` from
     - Parameter state: The `State` to mutate
     - Parameter action: The `Action` dispatched
     */
    public init(id: String = UUID().uuidString, reduce: @escaping (_ state: inout State, _ action: Action) -> Void) {
        self.id = id
        self.reduce = reduce
    }

    /**
     Creates a `Reducer` from a list of `ReduceOn`s.

     - Parameter reduceOns: The `ReduceOn`s which the created `Reducer` should contain
     */
    public init(id: String = UUID().uuidString, _ reduceOns: ReduceOn<State>...) {
        self.id = id
        self.reduce = { state, action in
            reduceOns.forEach { $0.reduce(&state, action) }
        }
    }
}

/// A part of a `Reducer` which only gets triggered on certain `Action`s or `ActionTemplate`s.
public struct ReduceOn<State> {
    /// A pure function which takes the a `State` and an `Action` and returns a new `State`.
    public let reduce: (inout State, Action) -> Void

    /**
     Creates a `ReduceOn` which only runs `reduce` with actions of the type specificed in `actionType`.

     - Parameter actionType: The type of `Action` to filter on
     - Parameter reduce: A pure function which takes a `State` and an `Action` and returns a new `State`.
     - Parameter state: The `State` to mutate
     - Parameter action: The `Action` dispatched
     */
    public init<A: Action>(_ actionType: A.Type, reduce: @escaping (_ state: inout State, _ action: A) -> Void) {
        self.reduce = { state, action in
            guard let action = action as? A else { return }
            reduce(&state, action)
        }
    }

    /**
     Creates a `ReduceOn` which only runs `reduce` with actions created from the specificed `ActionTemplate`s.

     - Parameter actionTemplates: The `ActionTemplate`s to filter on
     - Parameter reduce: A pure function which takes a `State` and an `Action` and returns a new `State`.
     - Parameter state: The `State` to mutate
     - Parameter action: The `Action` dispatched
     */
    public init<Payload>(_ actionTemplates: ActionTemplate<Payload>...,
                         reduce: @escaping (_ state: inout State, _ action: AnonymousAction<Payload>) -> Void) {
        self.reduce = { state, action in
            guard let anonymousAction = action as? AnonymousAction<Payload> else { return }
            guard actionTemplates.contains(where: { anonymousAction.wasCreated(from: $0) }) else { return }
            reduce(&state, anonymousAction)
        }
    }
}
