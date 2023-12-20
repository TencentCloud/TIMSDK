//
//  TopItemView.swift
//  TUIRoomKit
//
//  Created by 唐佳宁 on 2022/12/30.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation

class TopItemView: UIView {
    let itemData: ButtonItemData
    
    let button: UIButton = {
        let button = UIButton(type: .custom)
        return button
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
        self.layer.cornerRadius = 10
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(button)
    }
    
    func activateConstraints() {
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }
    
    func bindInteraction() {
        setupViewState(item: itemData)
        button.addTarget(self, action: #selector(clickMenuButton(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: ButtonItemData) {
        button.isSelected = item.isSelect
        button.isEnabled = item.isEnabled
        button.isHidden = item.isHidden
        if let normalImage = item.normalImage {
            button.setImage(normalImage, for: .normal)
        }
        if let selectedImage = item.selectedImage {
            button.setImage(selectedImage, for: .selected)
        }
        if let disabledImage = item.disabledImage {
            button.setImage(disabledImage, for: .disabled)
        }
    }
    
    @objc
    func clickMenuButton(sender: UIButton) {
        itemData.action?(sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
