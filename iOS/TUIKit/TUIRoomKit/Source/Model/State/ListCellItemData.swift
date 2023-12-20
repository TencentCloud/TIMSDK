//
//  ListCellItemData.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class ListCellItemData {
    enum ListCellType {
        case resolutionType
        case frameRateType
        case bitrateType
        case captureVolumeType
        case playingVolumeType
        case volumePromptType
        case normal
    }
    var type: ListCellType = .normal
    var size: CGSize?
    var backgroundColor: UIColor = .clear
    //UILabel配置
    var titleText: String = ""
    var messageText: String = ""
    //UISwitch配置
    var hasSwitch: Bool = false
    var isSwitchOn: Bool = false
    //UIButton配置
    var hasRightButton: Bool = false
    var buttonData: ButtonItemData?
    //UISlider配置
    var hasSliderLabel: Bool = false
    var hasSlider: Bool = false
    var minimumValue: Float = 0
    var maximumValue: Float = 100
    var sliderStep: Float = 1
    var sliderUnit: String = ""
    var sliderDefault: Float = 0
    //点击事件配置
    var action: ((Any)->Void)?
    var hasOverAllAction: Bool = false
    //下划线配置
    var hasDownLineView: Bool = false
}
