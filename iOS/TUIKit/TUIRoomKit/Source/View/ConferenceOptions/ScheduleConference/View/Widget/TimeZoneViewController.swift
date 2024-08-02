//
//  TimeZoneViewController.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/27.
//

import Foundation

class TimeZoneViewController: UIViewController {
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func loadView() {
        self.view = TimeZoneView()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
