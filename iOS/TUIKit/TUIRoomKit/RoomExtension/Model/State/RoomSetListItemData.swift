//
//  RoomSetListItemData.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/6/27.
//

import Foundation

class RoomSetListItemData {
    var titleText: String = ""
    var isSwitchOn: Bool = false
    var action: ((Any)->Void)?
}
