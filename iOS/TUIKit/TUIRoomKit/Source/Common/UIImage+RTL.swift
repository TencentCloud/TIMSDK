//
//  UIImage+RTL.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/8/31.
//

import Foundation

extension UIImage {
    func checkOverturn() -> UIImage? {
        if isRTL {
            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            guard let bitmap: CGContext = UIGraphicsGetCurrentContext() else { return nil }
            guard let cgImage = self.cgImage else { return nil }
            bitmap.translateBy(x: self.size.width / 2, y: self.size.height / 2)
            bitmap.scaleBy(x: -1.0, y: -1.0)
            bitmap.translateBy(x: -self.size.width / 2, y: -self.size.height / 2)
            bitmap.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return self
    }
}
