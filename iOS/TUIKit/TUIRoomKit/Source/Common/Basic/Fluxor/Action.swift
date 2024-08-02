/*
 * Fluxor
 *  Copyright (c) Morten Bjerg Gregersen 2020
 *  MIT license, see LICENSE file for details
 */

import Foundation

/**
 An event happening in an application.

 `Action`s are dispatched on the `Store`.
 */
public protocol Action {}

/// An `Action` which can be encoded.
public protocol EncodableAction: Action, Encodable {
    /**
     To enable encoding of the `Action` this helper function is needed.

     `JSONEncoder` can't encode an `Encodable` type unless it has the specific type.
         By using an `extension` of the `Action` we have this specific type and can encode it.
     */
    func encode(with encoder: JSONEncoder) -> Data?
}

public extension EncodableAction {
    func encode(with encoder: JSONEncoder) -> Data? {
        return try? encoder.encode(self)
    }
}

/**
 A template for creating `Action`s.

 The template can have a `Payload`type which is used when creating an actual `Action` from the template.
 */
public struct ActionTemplate<Payload> {
    /// The identifier for the `ActionTemplate`
    public let id: String
    /// The type of the `Payload`
    public let payloadType: Payload.Type

    /**
     Initializes an `ActionTemplate` with the given `payloadType`.

     - Parameter id: The identifier for the `ActionTemplate`
     - Parameter payloadType: The type of the `Payload`
     */
    public init(id: String, payloadType: Payload.Type) {
        self.id = id
        self.payloadType = payloadType
    }

    /**
     Creates an `AnonymousAction` with the `ActionTemplate`s `id` and the given `payload`.

      - Parameter payload: The payload to create the `AnonymousAction` with
     */
    public func createAction(payload: Payload) -> AnonymousAction<Payload> {
        return .init(id: id, payload: payload)
    }

    /**
     Creates an `AnonymousAction` with the `ActionTemplate`s `id` and the given `payload`.

      - Parameter payload: The payload to create the `AnonymousAction` with
     */
    public func callAsFunction(payload: Payload) -> AnonymousAction<Payload> {
        return createAction(payload: payload)
    }
}

public extension ActionTemplate where Payload == Void {
    /**
     Initializes an `ActionTemplate` with no `Payload`.

     - Parameter id: The identifier for the `ActionTemplate`
     */
    init(id: String) {
        self.init(id: id, payloadType: Payload.self)
    }

    /**
     Creates an `AnonymousAction` with the `ActionTemplate`s `id`.
     */
    func createAction() -> AnonymousAction<Payload> {
        return .init(id: id, payload: ())
    }

    /**
     Creates an `AnonymousAction` with the `ActionTemplate`s `id`.
     */
    func callAsFunction() -> AnonymousAction<Payload> {
        return createAction()
    }
}

/// An `Action` with an identifier.
public protocol IdentifiableAction: Action {
    /// The identifier
    var id: String { get }
}

/// An `Action` created from an `ActionTemplate`.
public struct AnonymousAction<Payload>: IdentifiableAction {
    /// The identifier for the `AnonymousAction`
    public let id: String
    /// The `Payload` for the `AnonymousAction`
    public let payload: Payload

    /**
     Check if the `AnonymousAction` was created from a given `ActionTemplate`.

     - Parameter actionTemplate: The `ActionTemplate` to check
     */
    public func wasCreated(from actionTemplate: ActionTemplate<Payload>) -> Bool {
        return actionTemplate.id == id
    }
}

extension AnonymousAction: EncodableAction {
    private var encodablePayload: [String: AnyCodable]? {
        guard type(of: payload) != Void.self else { return nil }
        let mirror = Mirror(reflecting: payload)
        return mirror.children.reduce(into: [String: AnyCodable]()) {
            guard let key = $1.label else { return }
            $0[key] = AnyCodable($1.value)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        if payload is Encodable {
            try container.encode(AnyCodable(payload), forKey: .payload)
        } else {
            try container.encodeIfPresent(encodablePayload, forKey: .payload)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case payload
    }
}
