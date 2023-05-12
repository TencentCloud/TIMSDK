//
//  InviteUserButtonViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/4.
//

import Foundation
import TUICore

let TUICallKit_TUIGroupService_UserDataValue = "TUICallKit"

class InviteUserButtonViewModel {
    
    let mediaTypeObserver = Observer()
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)

    init() {
        mediaType.value = TUICallState.instance.mediaType.value

        registerObserve()
    }
    
    deinit {
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
    }
    
    func registerObserve() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.mediaType.value = newValue
        }
    }

    func inviteUser() {
        guard let nameKey = TUICallKitLocalize(key: "Demo.TRTC.Streaming.call") else { return }
        let param: [String: Any] = [
            TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_GroupID: TUICallState.instance.groupId.value,
            TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_SelectedUserIDList: TUICallState.instance.getUserIdList(),
            TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_Name: nameKey,]
        var viewController = TUICore.callService(TUICore_TUIGroupObjectFactory,
                                                 method: TUICore_TUIGroupObjectFactory_SelectGroupMemberVC,
                                                 param: param) as? UIViewController
        if viewController == nil {
            viewController = TUICore.callService(TUICore_TUIGroupObjectFactory_Minimalist,
                                                 method: TUICore_TUIGroupObjectFactory_SelectGroupMemberVC,
                                                 param: param) as? UIViewController
        }
        guard let viewController = viewController else { return }
        
        viewController.tui_valueCallback = tui_valueCallback
        
        let navigationController = TUINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        let keyWindow = TUICallKitCommon.getKeyWindow()
        keyWindow?.rootViewController?.present(navigationController, animated: false)
    }
    
    func tui_valueCallback(param: [AnyHashable: Any]) {
        guard let selectUserList = param[TUICore_TUIGroupObjectFactory_SelectGroupMemberVC_ResultUserList] as? [TUIUserModel] else { return }
        if selectUserList.count > 0 {
            return
        }
        
        var userIds: [String] = []
        for user in selectUserList {
            userIds.append(user.userId)
        }

        CallEngineManager.instance.inviteUser(userIds: userIds)
    }
}
