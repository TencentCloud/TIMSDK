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
        view.textAlignment = isRTL ? .left : .right
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
    
    lazy var rightButton: ButtonItemView = {
        let button = ButtonItemView(itemData: itemData.buttonData ?? ButtonItemData())
        return button
    }()
    
    let downLineView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x6B758A,alpha: 0.3)
        return view
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
        addSubview(downLineView)
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
            if itemData.hasRightButton  {
                make.trailing.equalTo(rightButton.snp.leading)
            } else if (itemData.hasSwitch) {
                make.trailing.equalTo(rightSwitch.snp.trailing)
            } else {
                make.trailing.equalToSuperview()
            }
            make.height.equalTo(20.scale375())
        }
        
        slider.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.width.equalTo(152.scale375())
            make.centerY.equalToSuperview()
        }
        
        sliderLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(5.scale375())
            make.trailing.equalTo(slider.snp.leading).offset(-5.scale375())
            make.centerY.equalToSuperview()
        }
        
        rightSwitch.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        rightButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            if let size = itemData.buttonData?.size {
                make.width.equalTo(size.width)
                make.height.equalTo(size.height)
            } else {
                make.width.equalTo(60.scale375())
                make.height.equalTo(26.scale375Height())
            }
        }
        downLineView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func bindInteraction() {
        setupViewState(item: itemData)
        if itemData.hasOverAllAction {
            let tap = UITapGestureRecognizer(target: self, action: #selector(overAllAction(sender:)))
            addGestureRecognizer(tap)
        }
        rightSwitch.addTarget(self, action: #selector(switchAction(sender:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(sliderAction(sender:)), for: .valueChanged)
    }
    
    func setupViewState(item: ListCellItemData) {
        //UILabel配置
        titleLabel.isHidden = item.titleText.isEmpty
        titleLabel.text = item.titleText
        messageLabel.isHidden = item.messageText.isEmpty
        messageLabel.text = item.messageText
        //UISwitch配置
        rightSwitch.isHidden = !item.hasSwitch
        rightSwitch.isOn = item.isSwitchOn
        //TUIButton配置
        rightButton.isHidden = !item.hasRightButton
        if let buttonData = item.buttonData {
            rightButton.setupViewState(item: buttonData)
        }
        //UISlider配置
        slider.isHidden = !item.hasSlider
        sliderLabel.isHidden = !item.hasSliderLabel
        slider.minimumValue = item.minimumValue / item.sliderStep
        slider.maximumValue = item.maximumValue / item.sliderStep
        slider.value = item.sliderDefault / item.sliderStep
        sliderLabel.text = String(Int(slider.value) * Int(item.sliderStep)) + item.sliderUnit
        //下划线配置
        downLineView.isHidden = !itemData.hasDownLineView
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
