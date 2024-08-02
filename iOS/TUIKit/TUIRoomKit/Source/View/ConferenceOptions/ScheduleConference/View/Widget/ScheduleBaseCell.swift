//
//  ScheduleBaseCell.swift
//  TUIRoomKit
//
//  Created by aby on 2024/6/28.
//

import UIKit
import Combine

class ScheduleBaseCell: UITableViewCell {
    var cancellableSet = Set<AnyCancellable>()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancellableSet.forEach { cancelable in
            cancelable.cancel()
        }
        cancellableSet.removeAll()
    }
}
