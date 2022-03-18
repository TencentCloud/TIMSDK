//
//  CommonUtils.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/19/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import Foundation

public extension UIStackView {

    func safelyRemoveArrangedSubviews() {

        // Remove all the arranged subviews and save them to an array
        let removedSubviews = arrangedSubviews.reduce([]) { (sum, next) -> [UIView] in
            self.removeArrangedSubview(next)
            return sum + [next]
        }

        // Deactive all constraints at once
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))

        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

public extension UIColor {
    
    @objc static var appTint: UIColor {
        return UIColor(hex: "006EFF") ?? UIColor(red: 54.0 / 255.0, green: 134.0 / 255.0, blue: 246.0 / 255.0, alpha: 1.0)
    }
    
    @objc static var searchBarBackColor: UIColor {
        return UIColor(hex: "#0D2C5B") ?? UIColor(red: 13.0 / 255.0, green: 44.0 / 255.0, blue: 91.0 / 255.0, alpha: 1.0)
    }
    
    @objc static var placeholderBackColor: UIColor {
        return UIColor(hex: "#6B82A8") ?? UIColor(red: 107.0 / 255.0, green: 130.0 / 255.0, blue: 168.0 / 255.0, alpha: 1.0)
    }
    
    @objc static var pannelBackColor: UIColor {
        return UIColor(hex: "#13233F") ?? UIColor(red: 19.0 / 255.0, green: 35.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0)
    }
    
    @objc static var buttonBackColor: UIColor {
        return UIColor(hex: "#0062E3") ?? UIColor(red: 0.12, green: 0.23, blue: 0.4, alpha: 1.0)
    }
    
    @objc static var verifyCodeBackColor: UIColor {
        return UIColor(hex: "#006EFD") ?? UIColor(red: 0.0, green: 110.0 / 255.0, blue: 253.0 / 255.0, alpha: 1.0)
    }
    
    @objc static var appBackGround: UIColor {
        return UIColor(hex: "#242424") ?? .black
    }
    
    @objc static var inputImageBackColor: UIColor {
        return UIColor(hex: "#092650") ?? UIColor(red: 9.0 / 255.0, green: 38.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
    }

    // MARK: - Initialization
    @objc convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        let length = hexSanitized.count
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Dictionary {
    func toJsonString() -> String {
        if let json = try? JSONSerialization.data(withJSONObject: self, options: []),
            let jsonStr = String(data: json, encoding: .utf8)
        {
            return jsonStr
        }
        fatalError()
    }
}

extension String {
    func toJson() -> [String: Any]? {
        if let infoData = data(using: .utf8),
            let dict = try? JSONSerialization.jsonObject(with: infoData, options: []) as? [String: Any]
        {
            return dict
        }
        return nil
    }
}
