//
//  Utils.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation

func DispatchCallKitMainAsyncSafe(closure: @escaping () -> Void) {
    if Thread.current.isMainThread {
        closure()
    } else {
        DispatchQueue.main.async(execute: closure)
    }
}

extension CGRect {
    func dividedIntegral(fraction: CGFloat, from fromEdge: CGRectEdge) -> (first: CGRect, second: CGRect) {
        let dimension: CGFloat
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            dimension = self.size.width
        case .minYEdge, .maxYEdge:
            dimension = self.size.height
        }
        
        let distance = (dimension * fraction).rounded(.up)
        var slices = self.divided(atDistance: distance, from: fromEdge)
        
        switch fromEdge {
        case .minXEdge, .maxXEdge:
            slices.remainder.origin.x += 1
            slices.remainder.size.width -= 1
        case .minYEdge, .maxYEdge:
            slices.remainder.origin.y += 1
            slices.remainder.size.height -= 1
        }
        
        return (first: slices.slice, second: slices.remainder)
    }
}

extension CGFloat {
    /// 375设计图中的尺寸
    ///
    /// - Returns: 最终结果缩放结果
    public func scaleWidth(_ exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? self * 1.5 : self * (Screen_Width / 375.00)
        }
        return self * (Screen_Width / 375.00)
    }
    
    public func scaleHeight(_ exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? self * 1.5 : self * (Screen_Height / 812.00)
        }
        return self * (Screen_Height / 812.00)
    }
}

extension Int {
    /// 375设计图中的尺寸
    ///
    /// - Returns: 最终结果缩放结果
    public func scaleWidth(_ exceptPad: Bool = true) -> CGFloat {
        return CGFloat(self).scaleWidth()
    }
    
    public func scaleHeight(_ exceptPad: Bool = true) -> CGFloat {
        return CGFloat(self).scaleHeight()
    }
}
