//
//  RoomReducer.swift
//  TUIRoomKit
//
//  Created by jeremiawang on 2024/8/19.
//

import Foundation

let roomReducer = Reducer<RoomInfo>(
    ReduceOn(RoomActions.updateRoomState, reduce: { state, action in
        state = action.payload
        state.isEnteredRoom = true
    }),
    ReduceOn(RoomActions.clearRoomState, reduce: { state, action in
        state = RoomInfo()
    })
)
