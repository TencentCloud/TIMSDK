//
//  UIColor+Style.swift
//  TUIRoomKit
//
//  Created by aby on 2022/12/27.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation

extension UIColor {
    public convenience init(_ hex: Int, alpha: CGFloat = 1.0) {
        assert(0...0xFFFFFF ~= hex, "The color hex value  must between 0 to 0XFFFFFF")
        let red = (hex & 0xFF0000) >> 16
        let green = (hex & 0x00FF00) >> 8
        let blue = (hex & 0x0000FF)
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: alpha
        )
    }
    
    public func trans2Image() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage ?? UIImage()
    }
}

extension UIView {
    func roundedRect(rect:CGRect, byRoundingCorners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath(roundedRect: rect, byRoundingCorners: byRoundingCorners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func roundedCircle(rect: CGRect) {
        roundedRect(rect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.size.width / 2, height: bounds.size.height / 2))
    }
}
