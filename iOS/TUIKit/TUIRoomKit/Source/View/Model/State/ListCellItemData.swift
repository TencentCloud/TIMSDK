//
//  ListCellItemData.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class ListCellItemData {
    enum ListCellType {
        case resolutionType
        case frameRateType
        case normal
    }
    var type: ListCellType = .normal
    var size: CGSize?
    var backgroundColor: UIColor = .clear
    //UILabel configuration
    var titleText: String = ""
    var messageText: String = ""
    var titleColor: UIColor?
    var messageColor: UIColor?
    //UISwitch configuration
    var hasSwitch: Bool = false
    var isSwitchOn: Bool = false
    //UIButton configuration
    var hasRightButton: Bool = false
    var buttonData: ButtonItemData?
    //UISlider configuration
    var hasSliderLabel: Bool = false
    var hasSlider: Bool = false
    var minimumValue: Float = 0
    var maximumValue: Float = 100
    var sliderStep: Float = 1
    var sliderUnit: String = ""
    var sliderDefault: Float = 0
    var action: ((Any)->Void)?
    var hasOverAllAction: Bool = false
    var hasDownLineView: Bool = false
}
