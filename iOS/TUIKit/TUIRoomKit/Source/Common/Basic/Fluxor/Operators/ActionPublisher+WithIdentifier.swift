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
     Only lets `AnonymousAction`s with a certain identifier get through the stream.

         actions
             .withIdentifier("FetchTodosAction")
             .sink(receiveValue: { action in
                 print("This is an AnonymousAction with the id 'FetchTodosAction': \(action)")
             })

     - Parameter identifierToMatch: A identifier to match
     */
    func withIdentifier(_ identifierToMatch: String) -> AnyPublisher<Action, Self.Failure> {
        filter { ($0 as? IdentifiableAction)?.id == identifierToMatch }
            .eraseToAnyPublisher()
    }
}
