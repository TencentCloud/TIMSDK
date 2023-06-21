//
//  RoomInviteViewController.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

//收到邀请页面
class RoomInviteViewController: UIViewController {
    let roomView: RoomInviteView
    let viewModel: RoomInviteViewModel
    init(inviteUserName: String,inviteUserAvatarUrl: String, roomId: String) {
        viewModel = RoomInviteViewModel(inviteUserName: inviteUserName, inviteUserAvatarUrl:inviteUserAvatarUrl, roomId: roomId)
        roomView = RoomInviteView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = roomView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.stopPlay()
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
