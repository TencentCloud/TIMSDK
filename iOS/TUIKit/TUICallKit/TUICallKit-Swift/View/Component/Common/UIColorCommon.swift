//
//  UIColorCommon.swift
//  TUICallKitSwift
//
//  Created by vincepzhang on 2023/1/3.
//

import UIKit

extension UIColor {
    
    static func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        var colorImage: UIImage
        var rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        context.setFillColor(color.cgColor)
        context.fill(rect)
        guard let cImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
        colorImage = cImage
        UIGraphicsEndImageContext()
        return colorImage
    }
    
    static func t_colorWithHexString(color: String) -> UIColor {
        return UIColor.t_colorWithHexString(color: color, alpha: 1)
    }
    
    static func t_colorWithHexString(color: String, alpha: CGFloat) -> UIColor {
        var colorString: String = color.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if colorString.count < 6 {
            return UIColor.clear
        }
        
        if colorString.hasPrefix("0X") {
            colorString = colorString.substring(from: colorString.index(colorString.startIndex, offsetBy: 2))
        }
        
        if colorString.hasPrefix("#") {
            colorString = colorString.substring(from: colorString.index(colorString.startIndex, offsetBy: 1))
        }
        
        if colorString.count < 6 {
            return UIColor.clear
        }
        
        let rString = String(colorString.prefix(2))
        colorString.removeFirst(2)
        let gString = String(colorString.prefix(2))
        colorString.removeFirst(2)
        let bString = String(colorString.prefix(2))
        
        var r = Int32()
        var g = Int32()
        var b = Int32()
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
    
        return  UIColor(red: CGFloat(r) / 255.0 , green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    static func t_colorWithAlphaHexString(color: String) -> UIColor {
        var colorString: String = color.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if colorString.count < 6 {
            return UIColor.clear
        }
        
        if colorString.hasPrefix("0X") {
            colorString = colorString.substring(from: colorString.index(colorString.startIndex, offsetBy: 2))
        }
        
        if colorString.hasPrefix("#") {
            colorString = colorString.substring(from: colorString.index(colorString.startIndex, offsetBy: 1))
        }
        
        if colorString.count < 6 {
            return UIColor.clear
        }
        
        let rString = String(colorString.prefix(2))
        colorString.removeFirst(2)
        let gString = String(colorString.prefix(2))
        colorString.removeFirst(2)
        let bString = String(colorString.prefix(2))
        colorString.removeFirst(2)
        let alphaString = String(colorString.prefix(2))
        
        var r: Float = Float()
        var g: Float = Float()
        var b: Float = Float()
        var alpha: Float = Float()
        Scanner(string: rString).scanHexFloat(&r)
        Scanner(string: gString).scanHexFloat(&g)
        Scanner(string: bString).scanHexFloat(&b)
        Scanner(string: alphaString).scanHexFloat(&alpha)
        
        return  UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(alpha))
    }

}
