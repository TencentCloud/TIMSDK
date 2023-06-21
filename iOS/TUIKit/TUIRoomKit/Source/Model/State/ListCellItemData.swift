//
//  ListCellItemData.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class ListCellItemData {
    
    var titleText: String = ""
    var messageText: String = ""
    var fieldPlaceholderText: String = ""
    var fieldText: String = ""
    var fieldEnable: Bool = false
    var isSwitchOn: Bool = false
    var action: ((Any)->Void)?
    var normalIcon: String = ""
    var selectedIcon: String = ""
    var disabledIcon: String = ""
    var resourceBundle: Bundle = Bundle.main
    var normalImage: UIImage? {
        return UIImage(named: normalIcon, in: resourceBundle, compatibleWith: nil)
    }
    var selectedImage: UIImage? {
        return UIImage(named: selectedIcon, in: resourceBundle, compatibleWith: nil)
    }
    var minimumValue: Float = 0
    var maximumValue: Float = 100
    var sliderStep: Float = 1
    var sliderUnit: String = ""
    var sliderDefault: Float = 0
    
    var hasSwitch: Bool = false
    var hasButton: Bool = false
    var hasFieldView: Bool = false
    var hasOverAllAction: Bool = false
    var hasSlider: Bool = false
    var hasSliderLabel: Bool = false
    var size: CGSize?
    var backgroundColor: UIColor?
}
