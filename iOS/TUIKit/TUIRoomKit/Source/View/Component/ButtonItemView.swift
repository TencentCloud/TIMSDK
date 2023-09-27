//
//  ButtonItemView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2023/1/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

import Foundation

class ButtonItemView: UIView {    
    let itemData: ButtonItemData
    
    let controlButton: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .bottom
        button.contentHorizontalAlignment = isRTL ? .right : .left
        button.setTitleColor(UIColor(0xD5E0F2), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 14)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10.scale375(), bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return button
    }()
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(0x4F586B,alpha: 0.1)
        return view
    }()
    // MARK: - initialized function
    init(itemData: ButtonItemData) {
        self.itemData = itemData
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - view layout
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
        addSubview(controlButton)
        addSubview(lineView)
    }
    
    func activateConstraints() {
        controlButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16.scale375())
            make.left.right.equalToSuperview()
            make.height.equalTo(20.scale375())
        }
        if itemData.buttonType == .muteMessageItemType {
            lineView.snp.remakeConstraints { make in
                make.top.equalToSuperview().offset(52.scale375())
                make.left.right.equalToSuperview()
                make.height.equalTo(5.scale375Height())
            }
        } else {
            lineView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(52.scale375())
                make.left.right.equalToSuperview()
                make.height.equalTo(1.scale375())
            }
        }
    }
    
    func bindInteraction() {
        setupViewState(item: itemData)
        controlButton.addTarget(self, action: #selector(clickMenuButton(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: ButtonItemData) {
        controlButton.isSelected = item.isSelect
        controlButton.isEnabled = item.isEnabled
        if let normalImage = item.normalImage {
            controlButton.setImage(normalImage, for: .normal)
        }
        if let selectedImage = item.selectedImage {
            controlButton.setImage(selectedImage, for: .selected)
        }
        controlButton.setTitle(item.normalTitle, for: .normal)
        controlButton.setTitle(item.selectedTitle, for: .selected)
    }
    
    @objc func clickMenuButton(sender: UIButton) {
        itemData.action?(sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
