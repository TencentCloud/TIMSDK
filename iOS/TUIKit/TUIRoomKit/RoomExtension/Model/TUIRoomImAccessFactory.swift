//
//  TUIRoomImAccessFactory.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TUICore

class TUIRoomImAccessFactory: NSObject {
    static let shared = TUIRoomImAccessFactory()
    private override init() {
        super.init()
    }
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension TUIRoomImAccessFactory: TUIObjectProtocol {
    func onCreateObject(_ method: String, param: [AnyHashable : Any]?) -> Any? {
        if method == TUICore_TUIRoomImAccessFactory_GetRoomMessageContentViewMethod {
            guard let message = param?[TUICore_TUIRoomImAccessFactory_GetRoomMessageContentViewMethod_Message] as?
                    V2TIMMessage else { return UIView(frame: .zero) }
            let roomMessageModel = RoomMessageModel(message: message)
            let viewModel = RoomMessageContentViewModel(message: roomMessageModel)
            let view = RoomMessageContentView(viewModel: viewModel)
            return view
        }
        return nil
    }
}
