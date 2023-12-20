//
//  ButtonItemData.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class ButtonItemData {
    enum ButtonType {
        case memberItemType
        case muteAudioItemType
        case muteVideoItemType
        case raiseHandItemType
        case leaveSeatItemType
        case shareScreenItemType
        case chatItemType
        case moreItemType
        case inviteItemType
        case inviteSeatItemType
        case floatWindowItemType
        case recordItemType
        case setupItemType
        case dropItemType
        case changeHostItemType
        case muteMessageItemType
        case stepDownSeatItemType
        case kickOutItemType
        case normal
        case advancedSettingItemType
        case switchMicItemType
        case switchCamaraItemType
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
    
    var cornerRadius: CGFloat?
    var hasLineView: Bool = false
    var orientation: Orientation = .left //文字和按钮的相对位置，默认是图案在左，文字在右，为left
    var imageSize: CGSize?
    var size: CGSize?
    var backgroundColor: UIColor?
    var isSelect: Bool = false
    var isEnabled: Bool = true
    var isHidden: Bool = false
}
