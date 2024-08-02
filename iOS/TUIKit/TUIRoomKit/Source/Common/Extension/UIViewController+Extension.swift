//
//  UIViewController+Extension.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/26.
//

import UIKit

extension UIViewController {
    var interfaceOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation ?? .portrait
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
}
