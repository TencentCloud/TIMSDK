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
        view.textColor = UIColor(0x8F9AB2)
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.minimumScaleFactor = 0.5
        return view
    }()
    
    let messageLabel: UILabel = {
        let view = UILabel()
        view.backgroundColor = .clear
        view.textColor = UIColor(0xD5E0F2)
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.adjustsFontSizeToFitWidth = false
        view.minimumScaleFactor = 0.5
        return view
    }()
    
    let slider: UISlider = {
        let view = UISlider()
        return view
    }()
    
    let sliderLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = isRTL ? .right : .left
        view.backgroundColor = .clear
        view.textColor = UIColor(0xD1D9EC)
        view.font = UIFont(name: "PingFangSC-Medium", size: 14)
        view.adjustsFontSizeToFitWidth = true
        view.textAlignment = .center
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
        button.setTitleColor(UIColor(0xB2BBD1), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 12)
        button.backgroundColor = UIColor(0x6B758A).withAlphaComponent(0.7)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        return button
    }()
    
    init(itemData: ListCellItemData) {
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
    
    func constructViewHierarchy() {
        addSubview(titleLabel)
        addSubview(messageLabel)
        addSubview(slider)
        addSubview(sliderLabel)
        addSubview(rightSwitch)
        addSubview(rightButton)
    }
    
    func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(124.scale375())
            make.height.equalTo(20.scale375())
        }
        
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(80.scale375())
            make.centerY.equalToSuperview()
            make.width.equalTo(188.scale375())
            make.height.equalTo(20.scale375())
        }
        
        sliderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(85.scale375())
            make.trailing.equalToSuperview().offset(-185.scale375())
            make.centerY.equalToSuperview()
        }
        
        slider.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12.scale375())
            make.width.equalTo(152.scale375())
            make.centerY.equalToSuperview()
        }
        
        rightSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        if itemData.hasRightButton {
            rightButton.snp.remakeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview()
                make.width.equalTo(60.scale375())
                make.height.equalTo(26.scale375Height())
            }
        } else {
            rightButton.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.trailing.equalToSuperview().offset(-20.scale375())
            }
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
        if !item.hasSwitch {
            rightSwitch.isHidden = true
        }
        if !item.hasRightButton {
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
        rightButton.setTitle(item.normalText, for: .normal)
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
        debugPrint("deinit \(self)")
    }
}
