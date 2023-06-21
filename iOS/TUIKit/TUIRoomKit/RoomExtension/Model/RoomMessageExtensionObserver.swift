//
//  RoomMessageExtensionObserver.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/6/2.
//

import Foundation
import TUICore

class RoomMessageExtensionObserver: NSObject {
    static let shared = RoomMessageExtensionObserver()
    let roomMessageManager: RoomMessageManager = RoomMessageManager.shared
    private override init() {
        super.init()
    }
    deinit {
        debugPrint("deinit \(self)")
    }
}
extension RoomMessageExtensionObserver: TUIExtensionProtocol {
    func onGetExtension(_ key: String, param: [AnyHashable : Any]?) -> [TUIExtensionInfo]? {
        guard let groupID = param?[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] as? String else { return nil }
        guard groupID != "" else { return nil }
        var resultExtensionInfoList: [TUIExtensionInfo] = []
        if key == TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID {
            let info = TUIExtensionInfo()
            info.weight = 200
            info.text = .meetingText
            if let image = UIImage(named: "room_quick_meeting", in: tuiRoomKitBundle(), compatibleWith: nil) {
                info.icon = image
            }
            info.onClicked = { [weak self] param in
                guard let self = self else { return }
                if let vc = param[TUICore_TUIChatExtension_InputViewMoreItem_PushVC] as? UINavigationController {
                    self.roomMessageManager.navigateController = vc
                }
                if let groupId = param[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] as? String {
                    self.roomMessageManager.groupId = groupId
                }
                self.roomMessageManager.sendRoomMessageToGroup()
            }
            resultExtensionInfoList.append(info)
        }
        return resultExtensionInfoList
    }
}

private extension String {
    static var meetingText: String {
        localized("TUIRoom.quick.meeting")
    }
}


