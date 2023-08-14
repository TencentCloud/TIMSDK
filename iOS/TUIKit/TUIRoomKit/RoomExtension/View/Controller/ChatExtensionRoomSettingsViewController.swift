//
//  ChatExtensionRoomSettingsViewController.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/6/26.
//

import Foundation

class ChatExtensionRoomSettingsViewController: UIViewController {
    let roomView: ChatExtensionRoomSettingsView
    init(isOpenMicrophone: Bool, isOpenCamera: Bool) {
        let viewModel = ChatExtensionRoomSettingsViewModel(isOpenMicrophone: isOpenMicrophone, isOpenCamera: isOpenCamera)
        roomView = ChatExtensionRoomSettingsView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = roomView
    }
    
    override func viewDidLoad() {
        setNavBar()
    }
    
    private func setNavBar() {
        navigationItem.title = .roomDeviceSetText
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
private extension String {
    static var roomDeviceSetText: String {
        localized("TUIRoom.device.set")
    }
}
