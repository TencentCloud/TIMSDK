//
//  Button+Extension.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/3/16.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

enum ButtonEdgeInsetsStyle {
    // 图片相对于label的位置
    case Top
    case Left
    case Right
    case Bottom
}

extension UIButton {
    //style是imageView和titleLabel的相对位置，imageTitleSpace是imageView和titleLabel的间距
    func layoutButton(style: ButtonEdgeInsetsStyle, imageTitleSpace: CGFloat, imageFrame: CGSize? = nil, labelFrame: CGSize? = nil) {
        guard let imageWidth = (imageFrame != nil) ? imageFrame?.width : self.imageView?.frame.size.width else { return }
        guard let imageHeight = (imageFrame != nil) ?  imageFrame?.height : self.imageView?.frame.size.height else { return }
        guard let labelWidth = (labelFrame != nil) ? labelFrame?.width : self.titleLabel?.intrinsicContentSize.width else { return }
        guard let labelHeight = (labelFrame != nil) ? labelFrame?.height : self.titleLabel?.intrinsicContentSize.height else { return }
        var imageEdgeInsets = UIEdgeInsets.zero
        var labelEdgeInsets = UIEdgeInsets.zero
        switch style {
        case .Top:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight-imageTitleSpace/2, left: 0, bottom: 0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: -imageHeight-imageTitleSpace/2, right: 0)
        case .Left:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTitleSpace/2, bottom: 0, right: imageTitleSpace)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: imageTitleSpace/2, bottom: 0, right: -imageTitleSpace/2)
        case .Bottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight-imageTitleSpace/2, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight-imageTitleSpace/2, left: -imageWidth, bottom: 0, right: 0)
        case .Right:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+imageTitleSpace/2, bottom: 0, right: -labelWidth-imageTitleSpace/2)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth-imageTitleSpace/2, bottom: 0, right: imageWidth+imageTitleSpace/2)
        }
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
}
