//
//  SelectMemberViewFactory.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/18.
//

import Foundation
import RTCRoomEngine

struct MemberSelectParams {
    let selectedUsers: [User]
    let delegate: MemberSelectionDelegate
    let factory: MemberSelectionFactory
}

public protocol SelectMemberControllerProtocol: UIViewController {
    var delegate: MemberSelectionDelegate? { get set }
}

public protocol MemberSelectionDelegate: AnyObject {
    func onMemberSelected(_ viewController: SelectMemberControllerProtocol, invitees: [User])
}
