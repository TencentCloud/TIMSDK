//
//  ChatExtensionRoomSettingsItemView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/6/27.
//

import Foundation

class ChatExtensionRoomSettingsItemView: UIView {
    let itemData: RoomSetListItemData
    let titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = .black
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.minimumScaleFactor = 0.5
        return view
    }()
    
    let rightSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = true
        view.onTintColor = UIColor(0x0062E3)
        return view
    }()
    
    let line: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.alpha = 0.3
        return view
    }()
    
    init(itemData: RoomSetListItemData) {
        self.itemData = itemData
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    private func constructViewHierarchy() {
        addSubview(titleLabel)
        addSubview(rightSwitch)
        addSubview(line)
    }
    
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(100.scale375())
        }
        rightSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
        line.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-2)
            make.height.equalTo(0.5)
        }
    }
    
    private func bindInteraction() {
        backgroundColor = .white
        titleLabel.text = itemData.titleText
        rightSwitch.isOn = itemData.isSwitchOn
        rightSwitch.addTarget(self, action: #selector(switchAction(sender:)), for: .touchUpInside)
    }
    @objc func switchAction(sender: UISwitch) {
        itemData.action?(sender)
    }
}
