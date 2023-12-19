//
//  InviteUserButtonViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/4.
//

import Foundation
import TUICore
import TUICallEngine

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
        let selectGroupMemberVC = SelectGroupMemberViewController()
        selectGroupMemberVC.modalPresentationStyle = .fullScreen
        let keyWindow = TUICallKitCommon.getKeyWindow()
        keyWindow?.rootViewController?.present(selectGroupMemberVC, animated: false)
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
