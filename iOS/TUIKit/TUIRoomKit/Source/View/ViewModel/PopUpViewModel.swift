//
//  PopUpViewModel.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/12.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUICore

enum PopUpViewType {
    case roomInfoViewType
    case moreViewType
    case mediaSettingViewType
    case userListViewType
    case raiseHandApplicationListViewType
    case transferMasterViewType
    case QRCodeViewType
    case chatViewType
    case inviteViewType
    case inviteMemberViewType
}

protocol PopUpViewModelResponder: AnyObject {
    func searchControllerChangeActive(isActive: Bool)
    func updateViewOrientation(isLandscape: Bool)
}

class PopUpViewModel {
    let viewType: PopUpViewType
    let height: CGFloat
    var backgroundColor: UIColor?
    weak var viewResponder: PopUpViewModelResponder?
    
    init(viewType: PopUpViewType, height: CGFloat) {
        self.viewType = viewType
        self.height = height
    }
    
    func panelControlAction() {
        changeSearchControllerActive()
        RoomRouter.shared.dismissPopupViewController()
    }
    
    func changeSearchControllerActive() {
        viewResponder?.searchControllerChangeActive(isActive: false)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
