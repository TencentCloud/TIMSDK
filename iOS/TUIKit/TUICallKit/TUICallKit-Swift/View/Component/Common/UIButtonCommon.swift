//
//  UIButtonCommon.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/10.
//

import Foundation

enum TUIButtonEdgeInsetsStyle {
    case TUIButtonEdgeInsetsStyleTop
    case TUIButtonEdgeInsetsStyleLeft
    case TUIButtonEdgeInsetsStyleBottom
    case TUIButtonEdgeInsetsStyleRight
}

extension UIButton {
    
    func layoutButtonWithEdgeInsetsStyle(style: TUIButtonEdgeInsetsStyle, space: CGFloat) {
        let imageWidth = imageView?.frame.size.width ?? 0.0
        let imageHeight = imageView?.frame.size.height ?? 0.0
        let labelWidth = titleLabel?.intrinsicContentSize.width ?? 0.0
        let labelHeight = titleLabel?.intrinsicContentSize.height ?? 0.0
        var imageEdgeInsets: UIEdgeInsets = .zero
        var labelEdgeInsets: UIEdgeInsets = .zero
        switch style {
        case .TUIButtonEdgeInsetsStyleTop:
            imageEdgeInsets = UIEdgeInsets(top: -labelHeight - space / 2.0, left: 0, bottom: 0, right: -labelHeight)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth, bottom: -labelHeight - space / 2.0, right: 0)
            break
        case .TUIButtonEdgeInsetsStyleLeft:
            imageEdgeInsets = UIEdgeInsets(top: 0, left:  -space / 2.0, bottom: 0, right: space / 2.0)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: space / 2.0, bottom: 0 , right: -space / 2.0)
            break
        case .TUIButtonEdgeInsetsStyleBottom:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: -labelHeight - space / 2.0, right: -labelWidth)
            labelEdgeInsets = UIEdgeInsets(top: -imageHeight - space / 2.0, left: -imageWidth, bottom: 0 , right: 0)
            break
        case .TUIButtonEdgeInsetsStyleRight:
            imageEdgeInsets = UIEdgeInsets(top: 0, left: labelWidth+space / 2.0, bottom: 0, right: -labelWidth - space / 2.0)
            labelEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth - space / 2.0, bottom: 0 , right: imageWidth + space / 2.0)
            break
        }
        self.titleEdgeInsets = labelEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
    }
    
}
