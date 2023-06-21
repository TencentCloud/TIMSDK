//
//  RoomPrePareViewController.swift
//  Alamofire
//
//  Created by aby on 2022/12/26.
//  Copyright © 2022 Tencent. All rights reserved.
//

import UIKit

protocol RoomPrePareViewModelFactory {
    func makePrePareViewModel(enablePrepareView: Bool) -> PrePareViewModel
}

class RoomPrePareViewController: UIViewController {
    let viewModel: PrePareViewModel
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    init(roomPrePareViewModelFactory: RoomPrePareViewModelFactory, enablePrepareView: Bool) {
        self.viewModel = roomPrePareViewModelFactory.makePrePareViewModel(enablePrepareView: enablePrepareView)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.isIdleTimerDisabled = false
        UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        if let view = self.view as? PrePareView{
            self.viewModel.initialState(view: view.prePareView)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.closeLocalCamera()
        viewModel.closeLocalMicrophone()
    }
    
    override func loadView() {
        self.view = PrePareView(viewModel: viewModel)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
