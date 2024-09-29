//
//  SelectMemberViewFactory.swift
//  TUIRoomKit
//
//  Created by CY zhao on 2024/6/18.
//

import Foundation
import RTCRoomEngine

struct MemberSelectParams {
    let participants: ConferenceParticipants
    let delegate: ContactViewSelectDelegate
    let factory: MemberSelectionFactory
}

@objc public protocol ContactViewProtocol: AnyObject {
    var delegate: ContactViewSelectDelegate? { get set }
}

@objc public protocol ContactViewSelectDelegate: AnyObject {
    func onMemberSelected(_ viewController: ContactViewProtocol, invitees: [User])
}
