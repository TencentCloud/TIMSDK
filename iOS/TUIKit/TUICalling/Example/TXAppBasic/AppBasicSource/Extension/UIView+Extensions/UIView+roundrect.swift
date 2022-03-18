//
//  UIView+roundrect.swift
//  TRTCScene
//
//  Created by adams on 2021/4/8.
//

import Foundation

public extension UIView {
    /// 切部分圆角
    ///
    /// - Parameters:
    ///   - rect: 传入View的Rect
    ///   - byRoundingCorners: 裁剪位置
    ///   - cornerRadii: 裁剪半径
    func roundedRect(rect:CGRect, byRoundingCorners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: byRoundingCorners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 切圆角
    ///
    /// - Parameter rect: 传入view的Rect
    func roundedCircle(rect: CGRect) {
        roundedRect(rect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.size.width / 2, height: bounds.size.height / 2))
    }
}

public extension UIView {
    
    private struct AssociatedKeys {
        static var gradientLayerKey = "gradientLayerKey"
    }
    
    var gradientLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.gradientLayerKey) as? CAGradientLayer
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.gradientLayerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func removeGradientLayer() {
        guard let glayer = gradientLayer else {
            return
        }
        glayer.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    @discardableResult
    func gradient(colors: [CGColor]) -> CAGradientLayer {
        
        func createGradientLayer() -> CAGradientLayer {
            let gradientLayer = CAGradientLayer()
            gradientLayer.startPoint = .zero
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.locations = [0, 1]
            self.gradientLayer = gradientLayer
            return gradientLayer
        }
        
        guard let sublayers = layer.sublayers else {
            let gradientLayer = createGradientLayer()
            gradientLayer.colors = colors
            gradientLayer.frame = bounds
            layer.insertSublayer(gradientLayer, at: 0)
            self.gradientLayer = gradientLayer
            return gradientLayer
        }
        for sublayer in sublayers {
            if sublayer.isKind(of: CAGradientLayer.self) {
                let glayer = sublayer as! CAGradientLayer
                if let gcolors = glayer.colors as? [CGColor], gcolors == colors {
                    glayer.frame = bounds
                    self.gradientLayer = glayer
                    return glayer
                }
            }
        }
        let gradientLayer = createGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
        self.gradientLayer = gradientLayer
        return gradientLayer
    }
}
