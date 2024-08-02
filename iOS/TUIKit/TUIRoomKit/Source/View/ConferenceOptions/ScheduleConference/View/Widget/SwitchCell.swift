//
//  SwitchCell.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/13.
//

import Foundation

class SwitchCell: ScheduleBaseCell {
    static let identifier = "SwitchCell"
    var item: CellConfigItem?
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0x2B2E38)
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.textAlignment = isRTL ? .right : .left
        return view
    }()
    
    let rightSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = true
        view.onTintColor = UIColor(0x0062E3)
        return view
    }()
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(rightSwitch)
    }
    
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20.scale375())
            make.centerY.equalToSuperview()
        }
        rightSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20.scale375())
            make.centerY.equalToSuperview()
        }
    }
    
    private func bindInteraction() {
        rightSwitch.addTarget(self, action: #selector(switchAction(sender:)), for: .touchUpInside)
    }
    
    @objc func switchAction(sender: UISwitch) {
        item?.selectClosure?()
    }
    
    func updateView(item: CellConfigItem) {
        guard let switchItem  = item as? SwitchItem else { return }
        self.item = item
        titleLabel.text = switchItem.title
        rightSwitch.isOn = switchItem.isOn
        rightSwitch.isEnabled = switchItem.isEnable
    }
    
    deinit {
        debugPrint("deinit:\(self)")
    }
}
