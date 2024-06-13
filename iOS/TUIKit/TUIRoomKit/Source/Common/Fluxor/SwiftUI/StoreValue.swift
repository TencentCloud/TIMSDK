/**
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2021
 *  MIT license, see LICENSE file for details
 */

#if canImport(SwiftUI)

#if USE_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif
import SwiftUI

/**
 A property wrapper for observing a value in the `Store`.

     
     import SwiftUI

     struct DrawView: View {
         @StoreValue(Current.store, Selectors.canClear) private var canClear: Bool

         var body: some View {
             Button(action: { ... }, label: { Text("Clear") })
                 .disabled(!canClear)
         }
     }

 */
@propertyWrapper public struct StoreValue<State, Value> where Value: Equatable {
    /// The current value in the `Store`
    public var wrappedValue: Value { selectCurrent() }
    /// A `Publisher` for the selecterd value in the `Store`
    public var projectedValue: AnyPublisher<Value, Never>
    /// A closure for selecting the current value in the `Store`
    private let selectCurrent: () -> Value

    /**
     Initializes the `StoreValue` property wrapper with a `Store` and a `Selector`.

     - Parameter store: The `Store` to select the value from
     - Parameter selector: The `Selector` to use for selecting the value
     */
    public init<Environment>(_ store: Store<State, Environment>, _ selector: Selector<State, Value>) {
        projectedValue = store.select(selector)
            .removeDuplicates()
            .eraseToAnyPublisher()
        selectCurrent = { store.selectCurrent(selector) }
    }
}

#endif
