//
//  BottomItemView.swift
//  Alamofire
//
//  Created by aby on 2022/12/23.
//  Copyright © 2023 Tencent. All rights reserved.
//

import UIKit

class BottomItemView: UIView {
    
    let itemData: ButtonItemData
    
    let button: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
        button.titleLabel?.textColor = UIColor(0xD1D9EC)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.adjustsFontSizeToFitWidth = true
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
            make.edges.equalToSuperview()
        }
    }
    
    func bindInteraction() {
        setupViewState(item: itemData)
        button.addTarget(self, action: #selector(clickMenuButton(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: ButtonItemData) {
        button.isSelected = item.isSelect
        button.isEnabled = item.isEnabled
        if let normalImage = item.normalImage {
            button.setImage(normalImage, for: .normal)
        }
        if let selectedImage = item.selectedImage {
            button.setImage(selectedImage, for: .selected)
        }
        if let disabledImage = item.disabledImage {
            button.setImage(disabledImage, for: .disabled)
        }
        if !item.normalTitle.isEmpty {
            button.setTitle(item.normalTitle, for: .normal)
        }
        if !item.selectedTitle.isEmpty {
            button.setTitle(item.selectedTitle, for: .selected)
        }
        if !item.normalTitle.isEmpty || !item.selectedTitle.isEmpty {
            button.layoutButton(style: .Top, imageTitleSpace: 5, imageFrame: CGSize(width: 24, height: 24))
        } else {
            button.layoutButton(style: .Top, imageTitleSpace: 5, imageFrame: CGSize(width: 24, height: 24), labelFrame:
                                    CGSize(width: 0, height: 0))
        }
    }
    
    @objc
    func clickMenuButton(sender: UIView) {
        itemData.action?(sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
