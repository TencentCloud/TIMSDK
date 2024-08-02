//
//  CellConfigItem.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/19.
//

import Foundation
import Combine

enum ScheduleConfigCellType {
    case list
    case switcher
    case textField
    case button

    var cellIdentifier: String {
        switch self {
            case .list:
                return ScheduleTabCell.identifier
            case .switcher:
                return SwitchCell.identifier
            case .textField:
                return TextFieldCell.identifier
            case .button:
                return ButtonCell.identifier
        }
    }
}

typealias CellSelectClosure = ()->Void
typealias CellStateBinderClosure = (UITableViewCell, inout Set<AnyCancellable>)->Void

protocol CellConfigItem {
    var cellType: ScheduleConfigCellType { get }
    var title: String { get }
    var selectClosure: CellSelectClosure? { get set }
    var bindStateClosure: CellStateBinderClosure? { get set }
    var isEnable: Bool { get set }
}

struct ListItem: CellConfigItem {
    var cellType: ScheduleConfigCellType = .list
    var title: String
    var content: String = ""
    var isEnable: Bool = true
    
    var showButton: Bool = false
    var buttonIcon: String = "room_down_arrow1"
    
    var selectClosure: CellSelectClosure?
    var bindStateClosure: CellStateBinderClosure?
    
    var iconList: [String] = []
}

struct SwitchItem: CellConfigItem {
    var cellType: ScheduleConfigCellType = .switcher
    var title: String
    var isOn: Bool = true
    var isEnable: Bool = true
    
    var selectClosure: CellSelectClosure?
    var bindStateClosure: CellStateBinderClosure?
}

struct TextFieldItem: CellConfigItem {
    var cellType: ScheduleConfigCellType = .textField
    var title: String
    var selectClosure: CellSelectClosure?
    var bindStateClosure: CellStateBinderClosure?
    var saveTextClosure: ((String) -> Void)?
    var isEnable: Bool = true
    var content: String = ""
    var keyboardType: UIKeyboardType = .default
    var maxLengthInBytes: Int = 100
}

struct ButtonItem: CellConfigItem {
    var cellType: ScheduleConfigCellType = .button
    var title: String
    var selectClosure: CellSelectClosure?
    var bindStateClosure: CellStateBinderClosure?
    var isEnable: Bool = true
    var titleColor: UIColor?
    var backgroudColor: UIColor?
}
