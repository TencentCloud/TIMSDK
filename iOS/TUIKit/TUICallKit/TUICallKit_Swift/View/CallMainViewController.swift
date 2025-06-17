//
//  CallKitViewController.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import UIKit
import TUICore

class CallMainViewController: UIViewController {
        
    let mainView = CallMainView(frame: .zero)

    override func viewDidLoad(){
        super.viewDidLoad()
        
        view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        if let superview = mainView.superview {
            NSLayoutConstraint.activate([
                mainView.topAnchor.constraint(equalTo: superview.topAnchor),
                mainView.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                mainView.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                mainView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
}

class CallKitNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
