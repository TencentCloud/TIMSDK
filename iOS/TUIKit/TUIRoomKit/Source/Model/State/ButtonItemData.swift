//
//  ButtonItemData.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class ButtonItemData {
    enum ButtonType {
        case muteAudioItemType
        case muteVideoItemType
        case raiseHandItemType
        case leaveSeatItemType
        case shareScreenItemType
        case moreItemType
        case switchCamaraItemType
        case raiseHandApplyItemType
        case normal
    }
    enum Orientation {
        case left
        case right
    }
    var buttonType: ButtonType = .normal
    var normalIcon: String = ""
    var selectedIcon: String = ""
    var disabledIcon: String = ""
    
    var normalTitle: String = ""
    var selectedTitle: String = ""
    
    var titleFont: UIFont?
    var titleColor: UIColor?
    
    var resourceBundle: Bundle = Bundle.main
    
    var action: ((Any)->Void)?
    
    var normalImage: UIImage? {
        return UIImage(named: normalIcon, in: resourceBundle, compatibleWith: nil)?.checkOverturn()
    }
    
    var selectedImage: UIImage? {
        return UIImage(named: selectedIcon, in: resourceBundle, compatibleWith: nil)?.checkOverturn()
    }
    
    var disabledImage: UIImage? {
        return UIImage(named: disabledIcon, in: resourceBundle, compatibleWith: nil)?.checkOverturn()
    }
    
    var hasNotice: Bool = false
    var noticeText: String = ""
    
    var cornerRadius: CGFloat?
    var hasLineView: Bool = false
    var orientation: Orientation = .left
    var imageSize: CGSize?
    var size: CGSize?
    var backgroundColor: UIColor?
    var isSelect: Bool = false
    var isEnabled: Bool = true
    var isHidden: Bool = false
    var alpha: CGFloat = 1
}
