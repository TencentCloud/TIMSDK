//
//  BottomItemView.swift
//  Alamofire
//
//  Created by aby on 2022/12/23.
//  Copyright © 2023 Tencent. All rights reserved.
//

import UIKit

class BottomItemView: UIView {
    
    var itemData: ButtonItemData
    
    var engineManager: EngineManager {
        EngineManager.createInstance()
    }
    
    let button: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10.0)
        label.textColor = UIColor(0xD1D9EC)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
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
        self.layer.cornerRadius = 10
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(button)
        button.addSubview(imageView)
        button.addSubview(label)
    }
    
    func activateConstraints() {
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            if itemData.normalTitle.isEmpty, itemData.selectedTitle.isEmpty {
                make.centerY.equalToSuperview()
            } else {
                make.top.equalToSuperview().offset(7)
            }
            make.width.height.equalTo(24)
            make.centerX.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            if itemData.normalIcon.isEmpty, itemData.selectedIcon.isEmpty {
                make.centerY.equalToSuperview()
            } else {
                make.top.equalTo(imageView.snp.bottom).offset(2)
            }
            make.width.equalToSuperview()
            make.height.equalTo(14)
        }
    }
    
    func bindInteraction() {
        setupViewState(item: itemData)
        button.addTarget(self, action: #selector(clickMenuButton(sender:)), for: .touchUpInside)
    }
    
    func setupViewState(item: ButtonItemData) {
        itemData = item
        button.isSelected = item.isSelect
        button.isEnabled = item.isEnabled
        imageView.image = item.isSelect ? itemData.selectedImage : itemData.normalImage
        label.text = item.isSelect ? itemData.selectedTitle : itemData.normalTitle
        button.alpha = item.alpha
    }
    
    @objc
    func clickMenuButton(sender: UIView) {
        itemData.action?(sender)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
}
