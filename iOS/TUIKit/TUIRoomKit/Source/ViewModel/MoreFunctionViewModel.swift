//
//  MoreFunctionViewModel.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/12.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUICore

class MoreFunctionViewModel {
    private(set) var viewItems: [ButtonItemData] = []
    
    var engineManager: EngineManager {
        return EngineManager.createInstance()
    }
    var engineEventCenter: EngineEventCenter {
        return EngineEventCenter.shared
    }
    
    init() {
        createBottomData()
    }
    
    func createBottomData() {
        //聊天
        if hasTUIChatItem() {
            let chatItem = ButtonItemData()
            chatItem.normalIcon = "room_chat"
            chatItem.normalTitle = .chatText
            chatItem.resourceBundle = tuiRoomKitBundle()
            chatItem.action = { [weak self] sender in
                guard let self = self, let button = sender as? UIButton else { return }
                self.chatAction(sender: button)
            }
            viewItems.append(chatItem)
        }
        //设置
        let settingItem = ButtonItemData()
        settingItem.normalIcon = "room_setting"
        settingItem.normalTitle = .settingText
        settingItem.resourceBundle = tuiRoomKitBundle()
        settingItem.action = { [weak self] sender in
            guard let self = self, let button = sender as? UIButton else { return }
            self.settingAction(sender: button)
        }
        viewItems.append(settingItem)
    }
    
    private func hasTUIChatItem() -> Bool {
        return TUICore.getService(TUICore_TUIChatService) != nil
    }
    
    func settingAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        RoomRouter.shared.dismissPopupViewController(viewType: .moreViewType)
        RoomRouter.shared.presentPopUpViewController(viewType: .mediaSettingViewType, height: 300.scale375())
    }
    
    func chatAction(sender: UIButton) {
        RoomRouter.shared.dismissPopupViewController(viewType: .moreViewType)
        let user = engineManager.store.currentUser
        let roomInfo = engineManager.store.roomInfo
        RoomRouter.shared.pushToChatController(user: user, roomInfo: roomInfo)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

private extension String {
    static var settingText: String {
        localized("TUIRoom.setting")
    }
    static var chatText: String {
        localized("TUIRoom.chat")
    }
}
