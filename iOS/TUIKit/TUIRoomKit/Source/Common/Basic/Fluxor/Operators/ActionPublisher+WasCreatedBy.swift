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
     Only lets `Action`s created from the given `ActionTemplate`s get through the stream.

         actions
             .wasCreated(from: fetchTodosActionTemplate)
             .sink(receiveValue: { action in
                 print("This is a FetchTodosAction: \(action)")
             })

     - Parameter actionTemplate: An `ActionTemplate` to check
     */
    func wasCreated<Payload>(from actionTemplate: ActionTemplate<Payload>)
        -> AnyPublisher<AnonymousAction<Payload>, Self.Failure> {
        ofType(AnonymousAction<Payload>.self)
            .filter { $0.wasCreated(from: actionTemplate) }
            .eraseToAnyPublisher()
    }
}
