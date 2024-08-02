/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Dispatch
import Foundation
#if USE_OPENCOMBINE
import OpenCombine
import OpenCombineDispatch
public typealias ObservableObjectCompat = OpenCombine.ObservableObject
public typealias PublishedCompat = OpenCombine.Published
#else
import Combine
public typealias ObservableObjectCompat = Combine.ObservableObject
public typealias PublishedCompat = Combine.Published
#endif

/**
 The `Store` is a centralized container for a single-source-of-truth `State`.

 A `Store` is configured by registering all the desired `Reducer`s and  `Effects`.

 An `Environment` can be set up to enable dependency injection in `Effect`s.

 ## Usage
 To update the `State` callers dispatch `Action`s on the `Store`.

 ## Selecting
 To select a value in the `State` the callers can either use a `Selector` or a key path.
 It is possible to get a `Publisher` for the value or just to select the current value.

 ## Interceptors
 It is possible to intercept all `Action`s and `State` changes by registering an `Interceptor`.
 */
open class Store<State, Environment>: ObservableObjectCompat {
    /// The state of the `Store`. It can only be modified by the registered `Reducer`s when `Action`s are dispatched.
    @PublishedCompat public private(set) var state: State
    /// The environment passed to the `Effects`. The `Environment` can contain services and other dependencies.
    public let environment: Environment
    internal private(set) var stateHash = UUID()
    private let actions = PassthroughSubject<Action, Never>()
    private var reducers = [KeyedReducer<State>]()
    private var effects = [String: [AnyCancellable]]()
    private var interceptors = [AnyInterceptor<State>]()

    // MARK: - Initialization

    /**
     Initializes the `Store` with an initial `State`, an `Environment` and eventually `Reducer`s.

     - Parameter initialState: The initial `State` for the `Store`
     - Parameter environment: The `Environment` to pass to `Effect`s
     - Parameter reducers: The `Reducer`s to register
     */
    public init(initialState: State, environment: Environment, reducers: [Reducer<State>] = []) {
        state = initialState
        self.environment = environment
        reducers.forEach(register(reducer:))
    }

    deinit {
        debugPrint("deinit \(type(of: self))")
    }
    
    // MARK: - Dispatching

    /**
     Dispatches an `Action` and creates a new `State` by running the current `State` and the `Action`
     through all registered `Reducer`s.

     After the `State` is set, all registered `Interceptor`s are notified of the change.
     Lastly the `Action` is dispatched to all registered `Effect`s.

     - Parameter action: The `Action` to dispatch
     */
    public func dispatch(action: Action) {
        let oldState = state
        var newState = oldState
        reducers.forEach { $0.reduce(&newState, action) }
        stateHash = UUID()
        state = newState
        interceptors.forEach { $0.actionDispatched(action: action, oldState: oldState, newState: newState) }
        actions.send(action)
    }

    // MARK: - Reducers

    /**
     Registers the given `Reducer`. The `Reducer` will be run for all subsequent actions.

     - Parameter reducer: The `Reducer` to register
     */
    public func register(reducer: Reducer<State>) {
        register(reducer: reducer, for: \.self)
    }

    /**
     Registers the given `Reducer` for a slice of the `State`. The `Reducer` will be run for all subsequent actions.

     - Parameter reducer: The `Reducer` to register
     - Parameter keyPath: The `KeyPath` for which the `Reducer` should be run
     */
    public func register<Substate>(reducer: Reducer<Substate>, for keyPath: WritableKeyPath<State, Substate>) {
        reducers.append(KeyedReducer(keyPath: keyPath, reducer: reducer))
    }

    /**
     Unregisters the given `Reducer`. The `Reducer` will no longer be run when `Action`s are dispatched.

     - Parameter reducer: The `Reducer` to unregister
     */
    public func unregister<SomeState>(reducer: Reducer<SomeState>) {
        reducers.removeAll { $0.id == reducer.id }
    }

    // MARK: - Effects

    /**
     Registers the given `Effects`. The `Effects` will receive all subsequent actions.

     - Parameter effects: The `Effects` to register
     */
    public func register<E: Effects>(effects: E) where E.Environment == Environment {
        self.effects[E.id] = createCancellables(for: effects.enabledEffects)
    }

    /**
     Registers the given `Effect`s. The `Effect`s will receive all subsequent actions.

     - Parameter effects: The array of `Effect`s to register
     - Parameter id: The identifier for the `Effect`s. Only used to enable unregistering the `Effect`s later
     */
    public func register(effects: [Effect<Environment>], id: String = "*") {
        self.effects[id] = createCancellables(for: effects)
    }

    /**
     Registers the given `Effect`. The `Effect` will receive all subsequent actions.

     Only `Effect`s registered from a type conforming to `Effects` can be unregistered.

     - Parameter effect: The `Effect` to register
     - Parameter id: The identifier for the `Effect`. Only used to enable unregistering the `Effect` later
     */
    public func register(effect: Effect<Environment>, id: String = "*") {
        effects[id] = (effects[id] ?? []) + [createCancellable(for: effect)]
    }

    /**
     Unregisters the given `Effects`. The `Effects` will no longer receive any actions.

     - Parameter effects: The `Effects` to register
     */
    public func unregisterEffects<E: Effects>(ofType effects: E.Type) where E.Environment == Environment {
        self.effects.removeValue(forKey: effects.id) // An AnyCancellable instance calls cancel() when deinitialized
    }

    /**
     Unregisters the `Effect`s registered with the id, so they will no longer receive any actions.

     - Parameter id: The identifier used to register the `Effect`s
     */
    public func unregisterEffects(withId id: String) {
        effects.removeValue(forKey: id) // An AnyCancellable instance calls cancel() when deinitialized
    }

    // MARK: - Interceptors

    /**
     Registers the given `Interceptor`. The `Interceptor` will receive all subsequent `Action`s and state changes.

     - Parameter interceptor: The `Interceptor` to register
     */
    public func register<I: Interceptor>(interceptor: I) where I.State == State {
        interceptors.append(AnyInterceptor(interceptor))
    }

    /**
     Unregisters all registered `Interceptor`s of the given type.
     The `Interceptor`s will no longer receive any `Action`s or state changes.

     - Parameter interceptor: The type of`Interceptor` to unregister
     */

    public func unregisterInterceptors<I: Interceptor>(ofType interceptor: I.Type) where I.State == State {
        interceptors.removeAll { $0.originalId == interceptor.id }
    }

    // MARK: - Selecting

    /**
     Creates a `Publisher` for a `Selector`.

     - Parameter selector: The `Selector` to use when getting the value in the `State`
     - Returns: A `Publisher` for the `Value` in the `State`
     */
    open func select<Value>(_ selector: Selector<State, Value>) -> AnyPublisher<Value, Never> {
        $state.map { selector.map($0, stateHash: self.stateHash) }.eraseToAnyPublisher()
    }

    /**
     Gets the current value in the `State` for a `Selector`.

     - Parameter selector: The `Selector` to use when getting the value in the `State`
     - Returns: The current `Value` in the `State`
     */
    open func selectCurrent<Value>(_ selector: Selector<State, Value>) -> Value {
        selector.map(state, stateHash: stateHash)
    }
}

// MARK: - Void Environment

public extension Store where Environment == Void {
    /**
     Initializes the `Store` with an initial `State` and eventually `Reducer`s.

     Using this initializer will give all `Effects` a `Void` environment.

     - Parameter initialState: The initial `State` for the `Store`
     - Parameter reducers: The `Reducer`s to register
     */
    convenience init(initialState: State, reducers: [Reducer<State>] = []) {
        self.init(initialState: initialState, environment: (), reducers: reducers)
    }
}

// MARK: - Subscriptions

extension Store: Subscriber {
    public typealias Input = Action
    public typealias Failure = Never

    public func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    public func receive(_ input: Action) -> Subscribers.Demand {
        dispatch(action: input)
        return .unlimited
    }

    public func receive(completion _: Subscribers.Completion<Never>) {}
}

// MARK: - Private

private extension Store {
    /**
     Creates `Cancellable`s for the given `Effect`s.

     - Parameter effects: The `Effect`s to create `Cancellable`s for
     - Returns: The `Cancellable`s for the given `Effect`s
     */
    func createCancellables(for effects: [Effect<Environment>]) -> [AnyCancellable] {
        effects.map(createCancellable(for:))
    }

    /**
     Creates `Cancellable` for the given `Effect`.

     - Parameter effect: The `Effect` to create `Cancellable` for
     - Returns: The `Cancellable` for the given `Effect`
     */
    func createCancellable(for effect: Effect<Environment>) -> AnyCancellable {
        switch effect {
        case let .dispatchingOne(effectCreator):
            return effectCreator(actions.eraseToAnyPublisher(), environment)
                .receive(on: DispatchQueue.mainQueue)
                .sink(receiveValue: dispatch(action:))
        case let .dispatchingMultiple(effectCreator):
            return effectCreator(actions.eraseToAnyPublisher(), environment)
                .receive(on: DispatchQueue.mainQueue)
                .sink { $0.forEach(self.dispatch(action:)) }
        case let .nonDispatching(effectCreator):
            return effectCreator(actions.eraseToAnyPublisher(), environment)
        }
    }
}

/// A wrapper for a `Reducer` for a specific `KeyPath`.
private struct KeyedReducer<State> {
    let id: String
    let reduce: (inout State, Action) -> Void

    init<Substate>(keyPath: WritableKeyPath<State, Substate>, reducer: Reducer<Substate>) {
        id = reducer.id
        reduce = { state, action in
            var substate = state[keyPath: keyPath]
            reducer.reduce(&substate, action)
            state[keyPath: keyPath] = substate
        }
    }
}
