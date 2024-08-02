//
//  PrepareSettingItemView.swift
//  TUIRoomKit
//
//  Created by janejntang on 2023/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation
import UIKit

class PrepareSettingItemView: UIView {
    let itemData: PrepareSettingItemData
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0xD1D9EC)
        view.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.minimumScaleFactor = 0.5
        return view
    }()
    
    let messageLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0xD1D9EC)
        view.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        view.adjustsFontSizeToFitWidth = false
        view.numberOfLines = 0
        view.minimumScaleFactor = 0.5
        return view
    }()
    
    let textField: UITextField = {
        let view = UITextField()
        view.backgroundColor = .clear
        view.textColor = UIColor(0xD1D9EC)
        view.font = UIFont(name: "PingFangSC-Regular", size: 14)
        let color = UIColor(0xBBBBBB)
        view.keyboardType = .numberPad
        return view
    }()
    
    let rightSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = true
        view.onTintColor = UIColor(0x0062E3)
        return view
    }()
    
    lazy var rightButton: UIButton = {
        let button = UIButton(type: .custom)
        let normalIcon = UIImage(named: "room_drop_down")
        button.setImage(normalIcon, for: .normal)
        return button
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x6B758A,alpha: 0.3)
        return view
    }()
    
    init(itemData: PrepareSettingItemData) {
        self.itemData = itemData
        super.init(frame: .zero)
        self.setupViewState(item: itemData)
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
        addSubview(messageLabel)
        addSubview(textField)
        addSubview(rightSwitch)
        addSubview(rightButton)
        addSubview(downLineView)
    }
    
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(100.scale375())
        }
        
        messageLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(10.scale375())
            make.trailing.equalToSuperview().offset(-40)
            make.centerY.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.trailing.equalToSuperview().offset(-100)
            make.centerY.equalToSuperview()
        }
        
        rightSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.equalTo(42)
            make.height.equalTo(24)
        }
        
        rightButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        downLineView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func bindInteraction() {
        if itemData.hasOverAllAction {
            let tap = UITapGestureRecognizer(target: self, action: #selector(overAllAction(sender:)))
            addGestureRecognizer(tap)
        }
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: .touchUpInside)
        rightSwitch.addTarget(self, action: #selector(switchAction(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: PrepareSettingItemData) {
        if item.titleText.isEmpty {
            titleLabel.isHidden = true
        }
        if item.messageText.isEmpty {
            messageLabel.isHidden = true
        }
        if !item.hasFieldView {
            textField.isHidden = true
        }
        if !item.hasSwitch {
            rightSwitch.isHidden = true
        }
        if !item.hasButton {
            rightButton.isHidden = true
        }
        rightSwitch.isOn = item.isSwitchOn
        titleLabel.text = item.titleText
        messageLabel.text = item.messageText
        textField.isUserInteractionEnabled = item.fieldEnable
        textField.delegate = self
        if item.fieldEnable {
            let color = UIColor(0xBBBBBB)
            textField.attributedPlaceholder = NSAttributedString(string: item.fieldPlaceholderText,attributes:
                                                                    [NSAttributedString.Key.foregroundColor:color])
        } else {
            textField.text = item.fieldText
        }
        downLineView.isHidden = !item.hasDownLineView
    }
    
    @objc func overAllAction(sender: UIView) {
        itemData.action?(sender)
    }
    
    @objc func rightButtonAction(sender: UIButton) {
        itemData.action?(sender)
    }
    
    @objc func switchAction(sender: UISwitch) {
        itemData.action?(sender)
    }
    
    @objc func textFieldAction(sender: UITextField) {
        itemData.action?(sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}

extension PrepareSettingItemView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCount = 11
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            textField.text = textField.text?
                .replacingOccurrences(of: " ",
                                      with: "",
                                      options: .literal,
                                      range: nil)
                .addIntervalSpace(intervalStr: " ", interval: 3)
        }
        
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        if substringToReplace.count > 0 && string.count == 0 {
            return true
        }
        let count = textFieldText.count - substringToReplace.count + string.count
        
        let res = count <= maxCount
        return res
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textFieldAction(sender: textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldAction(sender: textField)
    }
}
