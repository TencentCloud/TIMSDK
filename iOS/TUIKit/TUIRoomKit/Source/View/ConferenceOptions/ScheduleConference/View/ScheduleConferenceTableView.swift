//
//  ScheduleConferenceTableView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/24.
//

import Foundation
import Factory

class ScheduleConferenceTableView: UIView {
    var menus: [Int: [CellConfigItem]]
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.sectionFooterHeight = 20.scale375Height()
        tableView.sectionHeaderHeight = 0
        tableView.register(ScheduleTabCell.self, forCellReuseIdentifier: ScheduleTabCell.identifier)
        tableView.register(SwitchCell.self, forCellReuseIdentifier: SwitchCell.identifier)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: TextFieldCell.identifier)
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.identifier)
        return tableView
    }()
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        backgroundColor = UIColor(0xF8F9FB)
    }
    
    init(menus: [Int : [CellConfigItem]]) {
        self.menus = menus
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func constructViewHierarchy() {
        addSubview(tableView)
    }
    
    private func activateConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16.scale375())
            make.trailing.equalToSuperview().offset(-16.scale375())
            make.bottom.equalToSuperview().offset(-10.scale375Height())
        }
    }
}

extension ScheduleConferenceTableView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let value = menus[section] else { return 0 }
        return value.count
    }
}

extension ScheduleConferenceTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = menus[indexPath.section] ?? []
        let item = items[indexPath.row]
        let identifier = item.cellType.cellIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier:identifier, for: indexPath)
        if let scheduleTabCell = cell as? ScheduleTabCell {
            scheduleTabCell.updateView(item: item)
        } else if let switchCell = cell as? SwitchCell {
            switchCell.updateView(item: item)
        } else if let textFieldCell = cell as? TextFieldCell {
            textFieldCell.updateView(item: item)
        } else if let buttonCell = cell as? ButtonCell {
            buttonCell.updateView(item: item)
        }
        if let baseCell = cell as? ScheduleBaseCell {
            item.bindStateClosure?(baseCell, &baseCell.cancellableSet)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let items = menus[indexPath.section] ?? []
        let item = items[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if cell is ScheduleTabCell {
            item.selectClosure?()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalHeight = 45.scale375Height()
        if indexPath.section == 0 {
            return normalHeight
        }
        guard let itemArray = menus[indexPath.section], let item = itemArray[safe: indexPath.item] else { return normalHeight }
        switch item.cellType {
        case .switcher, .textField:
            return 54.scale375Height()
        case .button:
            return 44.scale375Height()
        default:
            return normalHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let rows = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == 0 || indexPath.row == rows - 1 {
            var corner = UIRectCorner()
            if rows == 1 {
                corner = .allCorners
            } else if indexPath.row == 0 {
                corner = [.topLeft, .topRight]
            } else if indexPath.row == rows - 1 {
                corner = [.bottomLeft, .bottomRight]
            }
            cell.roundedRect(rect: cell.bounds,
                             byRoundingCorners: corner,
                             cornerRadii: CGSize(width: 12, height: 12))
        }
    }
}
