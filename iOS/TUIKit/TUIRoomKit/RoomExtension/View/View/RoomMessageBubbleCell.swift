//
//  RoomMsgCell.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TIMCommon

@objc(RoomMessageBubbleCell)
class RoomMessageBubbleCell: TUIBubbleMessageCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        guard self.container != nil else { return }
        let message = RoomMessageModel()
        let view = RoomMessageView(viewModel: RoomMessageViewModel(message: message))
        self.container.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func fill(with data: TUIBubbleMessageCellData) {
        super.fill(with: data)
        let customData = data as? RoomMessageBubbleCellData
        guard let messageModel = customData?.messageModel as? RoomMessageModel else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let subviewArray = self.container.subviews
            for view in subviewArray where view is RoomMessageView {
                guard let messageView = view as? RoomMessageView else { continue }
                messageView.viewModel.changeMessage(message: messageModel)
            }
        }
    }
    
    override class func getContentSize(_ data: TUIMessageCellData?) -> CGSize {
        return CGSize(width: 238, height: 157)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
