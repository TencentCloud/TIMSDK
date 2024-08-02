//
//  ViewRouteState.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/19.
//

import Foundation

enum NavigationAction<ViewRoute>: Equatable where ViewRoute: Equatable {
    case present(route: ViewRoute)
    case push(route: ViewRoute)
    case presented(route: ViewRoute)
}

typealias ConferenceNavigation = NavigationAction<ConferenceRoute>

struct ConferenceRouteState {
    var currentRouteAction: ConferenceNavigation = .presented(route: .none)
    var currentRoute: ConferenceRoute = .none
    var memberSelectionFactory: MemberSelectionFactory?
}

enum ConferenceNavigationAction {
    static let key = "conference.navigation.action"
    static let navigate = ActionTemplate(id: key.appending("navigate"), payloadType: ConferenceNavigation.self)
    static let setMemberSelectionFactory = ActionTemplate(id: key.appending(".setMemberSelectionFactory"), payloadType: MemberSelectionFactory.self)
}

let routeReducer = Reducer<ConferenceRouteState>(
    ReduceOn(ConferenceNavigationAction.navigate, reduce: { state, action in
        state.currentRouteAction = action.payload
        switch action.payload {
            case let .presented(route: route):
                state.currentRoute = route
            default:
                break
        }
    }),
    ReduceOn(ConferenceNavigationAction.setMemberSelectionFactory, reduce: { state, action in
        state.memberSelectionFactory = action.payload
    })
)
