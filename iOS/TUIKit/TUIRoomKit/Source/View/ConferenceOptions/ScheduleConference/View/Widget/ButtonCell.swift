//
//  ButtonCell.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/7/5.
//

import Foundation

class ButtonCell: ScheduleBaseCell {
    static let identifier = "ButtonCell"
    var item: CellConfigItem?
    
    let button: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 12
        return button
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
        contentView.addSubview(button)
    }
    
    private func activateConstraints() {
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindInteraction() {
        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
    }
    
    @objc func buttonAction(sender: UIButton) {
        item?.selectClosure?()
    }
    
    func updateView(item: CellConfigItem) {
        self.item = item
        guard let buttonItem  = item as? ButtonItem else { return }
        button.setTitle(buttonItem.title, for: .normal)
        button.setTitleColor(buttonItem.titleColor, for: .normal)
        button.backgroundColor = buttonItem.backgroudColor
    }
    
    deinit {
        debugPrint("deinit:\(self)")
    }
}
