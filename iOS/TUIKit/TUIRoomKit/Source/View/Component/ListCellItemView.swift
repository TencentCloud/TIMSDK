//
//  ListCellItemView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class ListCellItemView: UIView {
    let itemData: ListCellItemData
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0xD1D9EC)
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.minimumScaleFactor = 0.5
        return view
    }()
    
    let messageLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0xD1D9EC)
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
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
    
    let slider: UISlider = {
        let view = UISlider()
        return view
    }()
    
    let sliderLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = NSTextAlignment.left
        view.backgroundColor = .clear
        view.textColor = UIColor(0xD1D9EC)
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.adjustsFontSizeToFitWidth = true
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
        let normalIcon = UIImage(named: "room_drop_down", in: tuiRoomKitBundle(), compatibleWith: nil)
        button.setImage(normalIcon, for: .normal)
        return button
    }()
    
    init(itemData: ListCellItemData) {
        self.itemData = itemData
        super.init(frame: .zero)
        EngineEventCenter.shared.subscribeUIEvent(key: .TUIRoomKitService_ResignFirstResponder, responder: self)
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
    
    func constructViewHierarchy() {
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(textField)
        addSubview(slider)
        addSubview(sliderLabel)
        addSubview(rightSwitch)
        addSubview(rightButton)
    }
    
    func activateConstraints() {
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
        
        slider.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(10.scale375())
            make.trailing.equalToSuperview().offset(-100.scale375())
            make.centerY.equalToSuperview()
        }
        
        sliderLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20.scale375())
            make.width.equalTo(50.scale375())
            make.centerY.equalToSuperview()
        }
        
        rightSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func bindInteraction() {
        setupViewState(item: itemData)
        if itemData.hasOverAllAction {
            let tap = UITapGestureRecognizer(target: self, action: #selector(overAllAction(sender:)))
            addGestureRecognizer(tap)
        }
        rightButton.addTarget(self, action: #selector(rightButtonAction(sender:)), for: .touchUpInside)
        rightSwitch.addTarget(self, action: #selector(switchAction(sender:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderAction(sender:)), for: .valueChanged)
    }
    
    func setupViewState(item: ListCellItemData) {
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
        if !item.hasSlider {
            slider.isHidden = true
        }
        if !item.hasSliderLabel {
            sliderLabel.isHidden = true
        }
        rightSwitch.isOn = item.isSwitchOn
        slider.minimumValue = item.minimumValue / item.sliderStep
        slider.maximumValue = item.maximumValue / item.sliderStep
        slider.value = item.sliderDefault / item.sliderStep
        sliderLabel.text = String(Int(slider.value) * Int(item.sliderStep)) + item.sliderUnit
        titleLabel.text = item.titleText
        messageLabel.text = item.messageText
        if let normalImage = item.normalImage {
            rightButton.setImage(normalImage, for: .normal)
        }
        if let selectedImage = item.selectedImage {
            rightButton.setImage(selectedImage, for: .selected)
        }
        textField.isUserInteractionEnabled = item.fieldEnable
        textField.delegate = self
        if item.fieldEnable {
            let color = UIColor(0xBBBBBB)
            textField.attributedPlaceholder = NSAttributedString(string: item.fieldPlaceholderText,attributes:
                                                                    [NSAttributedString.Key.foregroundColor:color])
            textField.becomeFirstResponder()
        } else {
            textField.text = item.fieldText
        }
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
    
    @objc func sliderAction(sender: UISlider) {
        sliderLabel.text = String(Int(slider.value) * Int(itemData.sliderStep)) + itemData.sliderUnit
        itemData.action?(sender)
    }
    
    deinit {
        EngineEventCenter.shared.unsubscribeUIEvent(key: .TUIRoomKitService_ResignFirstResponder, responder: self)
        debugPrint("deinit \(self)")
    }
}

extension ListCellItemView: RoomKitUIEventResponder {
    func onNotifyUIEvent(key: EngineEventCenter.RoomUIEvent, Object: Any?, info: [AnyHashable : Any]?) {
        if key == .TUIRoomKitService_ResignFirstResponder {
            if textField.isFirstResponder {
                textField.resignFirstResponder()
            }
        }
    }
}

extension ListCellItemView: UITextFieldDelegate {
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldAction(sender: textField)
    }
}
