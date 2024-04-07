//
//  RoomMessageExtensionObserver.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/6/2.
//

import Foundation
import TUICore
import TIMCommon

class RoomMessageExtensionObserver: NSObject {
    static let shared = RoomMessageExtensionObserver()
    let roomMessageManager: RoomMessageManager = RoomMessageManager.shared
    var settingMenuNavigationController: UINavigationController?
    private override init() {
        super.init()
    }
    @objc private func pushChatExtensionRoomSettingsViewController() {
        if let nav = settingMenuNavigationController {
            let vc = ChatExtensionRoomSettingsViewController(isOpenMicrophone: EngineManager.createInstance().store.isOpenMicrophone,
                                                 isOpenCamera: EngineManager.createInstance().store.isOpenCamera)
            nav.pushViewController(vc, animated: true)
        }
    }
    deinit {
        debugPrint("deinit \(self)")
    }
}
extension RoomMessageExtensionObserver: TUIExtensionProtocol {
    func onGetExtension(_ key: String, param: [AnyHashable : Any]?) -> [TUIExtensionInfo]? {
        if key == TUICore_TUIChatExtension_InputViewMoreItem_ClassicExtensionID {
            guard let groupID = param?[TUICore_TUIChatExtension_InputViewMoreItem_GroupID] as? String, groupID != "" else { return nil }
            guard let isNeedRoom = param?[TUICore_TUIChatExtension_InputViewMoreItem_FilterRoom] as? Bool, !isNeedRoom else { return nil }
            let info = TUIExtensionInfo()
            info.weight = 200
            info.text = .meetingText
            let defaultImage = UIImage(named: "room_quick_meeting", in: tuiRoomKitBundle(), compatibleWith: nil) ?? UIImage()
            info.icon = TUICoreThemeConvert.getTUIDynamicImage(imageKey: "room_quick_meeting_image", defaultImage: defaultImage)
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
            return [info]
        }
        if key == TUICore_TUIContactExtension_MeSettingMenu_ClassicExtensionID {
            if let nav = param?[TUICore_TUIContactExtension_MeSettingMenu_Nav] as? UINavigationController {
                self.settingMenuNavigationController = nav
            }
            let data = TUICommonTextCellData()
            data.key = .roomDeviceSetText
            data.showAccessory = true
            let cell = TUICommonTextCell()
            cell.fill(with: data)
            cell.mm_h = 60
            cell.mm_w = UIScreen.main.bounds.width
            let tap = UITapGestureRecognizer(target: self, action: #selector(pushChatExtensionRoomSettingsViewController))
            cell.addGestureRecognizer(tap)
            let info = TUIExtensionInfo()
            let param = [TUICore_TUIContactExtension_MeSettingMenu_Weight: 460,
                           TUICore_TUIContactExtension_MeSettingMenu_View: cell,
                           TUICore_TUIContactExtension_MeSettingMenu_Data: data,
            ] as [String : Any]
            info.data = param
            return [info]
        }
        return nil
    }
}

private extension String {
    static var meetingText: String {
        localized("TUIRoom.quick.meeting")
    }
    static var roomDeviceSetText: String {
        localized("TUIRoom.device.set")
    }
}


