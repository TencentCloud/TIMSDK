//
//  RoomMsgCell.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/5/8.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import TIMCommon

@objc(RoomMessageCell)
class RoomMessageCell: TUIBubbleMessageCell {
    var customData: RoomMessageCellModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func fill(with data: TUIBubbleMessageCellData) {
        super.fill(with: data)
        self.customData = data as? RoomMessageCellModel
        guard let roomId = customData?.messageModel?.roomId as? String else { return }
        guard let view = customData?.getRoomMessageView(roomId: roomId) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let subviewArray = self.container.subviews
            for view in subviewArray where view is RoomMessageContentView {
                view.removeFromSuperview()
            }
            guard self.container != nil else { return }
            self.container.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
