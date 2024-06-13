/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

#if USE_OPENCOMBINE
import OpenCombine
#else
import Combine
#endif

/// Operators for narrowing down `Action`s in Publisher streams.
public extension Publisher where Output == Action {
    /**
     Only lets `Action`s of a certain type get through the stream.

         actions
             .ofType(FetchTodosAction.self)
             .sink(receiveValue: { action in
                 print("This is a FetchTodosAction: \(action)")
             })

     - Parameter typeToMatch: A type of `Action` to match
     */
    func ofType<T>(_ typeToMatch: T.Type) -> AnyPublisher<T, Self.Failure> {
        compactMap { $0 as? T }
            .eraseToAnyPublisher()
    }
}
